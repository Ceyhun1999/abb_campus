import Testing
@testable import abb_campus

@Suite("ValidationHelper")
struct ValidationHelperTests {

    @Test("Valid emails", arguments: ["student@abb.local", "a.b+c@mail.az", "USER@ABB.EDU"])
    func validEmails(email: String) {
        #expect(ValidationHelper.isValidEmail(email))
    }

    @Test("Invalid emails", arguments: ["", "student", "student@", "@abb.local", "student@abb"])
    func invalidEmails(email: String) {
        #expect(ValidationHelper.isValidEmail(email) == false)
    }

    @Test("Reset code must be 6 digits")
    func resetCode() {
        #expect(ValidationHelper.isValidResetCode("482951"))
        #expect(ValidationHelper.isValidResetCode("48295") == false)
        #expect(ValidationHelper.isValidResetCode("48295a") == false)
    }
}
