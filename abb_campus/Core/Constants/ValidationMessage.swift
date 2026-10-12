import Foundation

enum ValidationMessage {
    static let emptyEmail = "E-poçtu daxil edin."
    static let invalidEmail = "E-poçt düzgün formatda deyil."
    static let emptyPassword = "Şifrəni daxil edin."
    static let shortPassword = "Şifrə minimum 6 simvoldan ibarət olmalıdır."
    static let shortNewPassword = "Yeni şifrə minimum 8 simvoldan ibarət olmalıdır."
    static let passwordsDoNotMatch = "Şifrələr eyni deyil."
    static let invalidResetCode = "Kod 6 rəqəmdən ibarət olmalıdır."
    static let roleNotSelected = "Rol seçilməyib."
}
