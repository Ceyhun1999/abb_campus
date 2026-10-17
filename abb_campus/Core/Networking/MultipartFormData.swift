import Foundation

struct MultipartFormData {

    let boundary = "Boundary-\(UUID().uuidString)"
    private(set) var body = Data()

    var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    mutating func addField(name: String, value: String) {
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        append("\(value)\r\n")
    }

    mutating func addFile(
        name: String,
        fileName: String,
        mimeType: String,
        data: Data
    ) {
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
        append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        append("\r\n")
    }

    func finalized() -> Data {
        var result = body
        result.append(Data("--\(boundary)--\r\n".utf8))
        return result
    }

    private mutating func append(_ string: String) {
        body.append(Data(string.utf8))
    }
}

// MARK: - Spreadsheet

extension MultipartFormData {

    /// A form with an Excel or CSV file in the "file" field, plus optional text fields.
    static func spreadsheet(fileName: String, data: Data, fields: [String: String] = [:]) -> MultipartFormData {
        var form = MultipartFormData()

        for (name, value) in fields.sorted(by: { $0.key < $1.key }) {
            form.addField(name: name, value: value)
        }

        form.addFile(name: "file", fileName: fileName, mimeType: spreadsheetMimeType(for: fileName), data: data)
        return form
    }

    static func spreadsheetMimeType(for fileName: String) -> String {
        switch (fileName as NSString).pathExtension.lowercased() {
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "xls":
            return "application/vnd.ms-excel"
        case "csv":
            return "text/csv"
        default:
            return "application/octet-stream"
        }
    }
}
