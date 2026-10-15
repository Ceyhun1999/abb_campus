import SwiftUI
import UniformTypeIdentifiers

struct StudentImportView: View {

    @State private var viewModel: StudentImportViewModel

    init(viewModel: StudentImportViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private static let allowedTypes: [UTType] = [
        UTType(filenameExtension: "xlsx"),
        UTType(filenameExtension: "xls"),
        .commaSeparatedText
    ].compactMap { $0 }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Fayl \(viewModel.group.name) qrupuna idxal ediləcək. Sütunlar: first_name, last_name, email.")
                    .font(.manropeRegular(14))
                    .foregroundStyle(.textSecondary)

                filePickerCard

                if let file = viewModel.selectedFile {
                    selectedFileRow(file)
                }

                PrimaryButton(
                    title: "Tələbələri idxal et",
                    isLoading: viewModel.result.isLoading
                ) {
                    Task {
                        await viewModel.importStudents()
                    }
                }
                .disabled(!viewModel.canImport)
                .opacity(viewModel.canImport ? 1 : 0.5)
                .accessibilityIdentifier("import_submit")

                if let result = viewModel.result.value {
                    resultSection(result)
                }
            }
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.vertical, 20)
        }
        .background(.appBackground)
        .errorAlert(viewModel.errorMessage, onDismiss: viewModel.dismissError)
        .navigationTitle("Tələbə importu")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $viewModel.isFilePickerPresented,
            allowedContentTypes: Self.allowedTypes
        ) { selection in
            viewModel.fileSelected(selection)
        }
        .sheet(isPresented: $viewModel.isErrorListPresented) {
            if let result = viewModel.result.value {
                ImportErrorsView(errors: result.errors)
            }
        }
    }

    // MARK: - File

    private var filePickerCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "tablecells.fill")
                .font(.system(size: 34))
                .foregroundStyle(.green)
                .frame(width: 64, height: 64)
                .background(Color.green.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text("Excel faylını seçin")
                .font(.manropeSemiBold(17))
                .foregroundStyle(.textPrimary)

            Text(".xlsx, .xls və .csv formatları dəstəklənir")
                .font(.manropeRegular(13))
                .foregroundStyle(.textSecondary)

            Button("Fayl seç") {
                viewModel.showFilePicker()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("pick_file_button")
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.blue.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
        )
    }

    private func selectedFileRow(_ file: SelectedFile) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.fill")
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.manropeSemiBold(15))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)

                Text(file.sizeDescription)
                    .font(.manropeRegular(12))
                    .foregroundStyle(.textSecondary)
            }

            Spacer()

            Button {
                viewModel.removeFile()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Faylı sil")
        }
        .padding(14)
        .cardStyle(cornerRadius: 14)
    }

    // MARK: - Result

    @ViewBuilder
    private func resultSection(_ result: StudentImportResult) -> some View {
        if result.isRejected {
            rejectedCard(result)
        } else {
            HStack(spacing: 14) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 2) {
                    Text("İdxal tamamlandı")
                        .font(.manropeBold(17))
                        .foregroundStyle(.textPrimary)

                    Text("\(result.imported) tələbə qrupa əlavə olundu")
                        .font(.manropeRegular(15))
                        .foregroundStyle(.textSecondary)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .cardStyle()
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("import_result")
        }
    }

    private func rejectedCard(_ result: StudentImportResult) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "xmark.octagon.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.red)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Fayl idxal edilmədi")
                        .font(.manropeBold(17))
                        .foregroundStyle(.textPrimary)

                    Text("\(result.errors.count) sətirdə səhv var. Heç bir tələbə əlavə olunmadı. Excel-i düzəldib yenidən yükləyin.")
                        .font(.manropeRegular(15))
                        .foregroundStyle(.textSecondary)
                }
            }

            Button("Səhv siyahısına bax") {
                viewModel.isErrorListPresented = true
            }
            .font(.manropeSemiBold(16))
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier("import_errors_button")
        }
        .padding(16)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityIdentifier("import_result")
    }
}

// MARK: - Errors

private struct ImportErrorsView: View {

    @Environment(\.dismiss) private var dismiss

    let errors: [StudentImportResult.RowError]

    var body: some View {
        NavigationStack {
            List(errors) { error in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sətir \(error.row)")
                        .font(.manropeSemiBold(15))

                    if let email = error.email {
                        Text(email)
                            .font(.manropeRegular(13))
                            .foregroundStyle(.secondary)
                    }

                    Text(error.message)
                        .font(.manropeRegular(14))
                        .foregroundStyle(.red)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Səhvlər")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Bağla") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
