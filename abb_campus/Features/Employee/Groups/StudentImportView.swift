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

        List {
            fileSection

            Section {
                Button {
                    Task {
                        await viewModel.importStudents()
                    }
                } label: {
                    if viewModel.result.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Tələbələri idxal et")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.canImport)
                .accessibilityIdentifier("import_submit")
            }

            if let result = viewModel.result.value {
                resultSection(result)
            }
        }
        .font(.manropeRegular(16))
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

    private var fileSection: some View {
        Section {
            if let file = viewModel.selectedFile {
                LabeledContent {
                    Button {
                        viewModel.removeFile()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Faylı sil")
                } label: {
                    Label {
                        Text(file.name)
                        Text(file.sizeDescription)
                    } icon: {
                        Image(systemName: "tablecells.fill")
                            .foregroundStyle(.green)
                    }
                }
            }

            Button {
                viewModel.showFilePicker()
            } label: {
                Label(viewModel.selectedFile == nil ? "Fayl seç" : "Başqa fayl seç", systemImage: "folder")
            }
            .accessibilityIdentifier("pick_file_button")
        } header: {
            Text("Excel faylı")
        } footer: {
            Text("Fayl \(viewModel.group.name) qrupuna idxal ediləcək. Sütunlar: first_name, last_name, email. Formatlar: .xlsx, .xls, .csv.")
        }
    }

    // MARK: - Result

    private func resultSection(_ result: StudentImportResult) -> some View {
        Section("İdxal nəticəsi") {
            LabeledContent {
                Text("\(result.imported)")
            } label: {
                Label("Uğurla əlavə olundu", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green, .primary)
            }

            LabeledContent {
                Text("\(result.skipped)")
            } label: {
                Label("Səhv olanlar", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red, .primary)
            }

            LabeledContent("Cəmi sətir", value: "\(result.totalRows)")

            if !result.errors.isEmpty {
                Button("Səhv siyahısına bax") {
                    viewModel.isErrorListPresented = true
                }
            }
        }
        .accessibilityIdentifier("import_result")
    }
}

private struct ImportErrorsView: View {

    @Environment(\.dismiss) private var dismiss

    let errors: [StudentImportResult.RowError]

    var body: some View {
        NavigationStack {
            List(errors) { error in
                LabeledContent {
                    EmptyView()
                } label: {
                    Text("Sətir \(error.row)")

                    if let email = error.email {
                        Text(email)
                    }

                    Text(error.message)
                        .foregroundStyle(.red)
                }
            }
            .font(.manropeRegular(16))
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
