import Foundation
import Testing
@testable import abb_campus

@Suite("APIErrorResponse")
struct APIErrorResponseTests {

    private func decode(_ json: String) throws -> APIErrorResponse {
        try JSONDecoder().decode(APIErrorResponse.self, from: Data(json.utf8))
    }

    @Test("All field errors are shown in a stable order without duplicates")
    func combinedErrors() throws {
        let response = try decode("""
        {"success": false, "message": "Doğrulama xətası",
         "errors": {"name": ["Bu adda qrup artıq mövcuddur."],
                    "mentorIds.1": ["Eyni mentor iki dəfə seçilib."],
                    "mentorIds.0": ["Eyni mentor iki dəfə seçilib."],
                    "endDate": ["Bitmə tarixini seçin."]}}
        """)

        #expect(response.combinedErrorMessage == """
        Bitmə tarixini seçin.
        Eyni mentor iki dəfə seçilib.
        Bu adda qrup artıq mövcuddur.
        """)
    }

    @Test("Without field errors the general message is used")
    func generalMessage() throws {
        let response = try decode(#"{"success": false, "message": "İcazə yoxdur."}"#)

        #expect(response.combinedErrorMessage == "İcazə yoxdur.")
    }
}
