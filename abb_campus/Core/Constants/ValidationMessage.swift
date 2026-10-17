import Foundation

enum ValidationMessage {
    static let emptyEmail = "E-poçtu daxil edin."
    static let invalidEmail = "E-poçt düzgün formatda deyil."
    static let emptyPassword = "Şifrəni daxil edin."
    static let shortPassword = "Şifrə minimum 6 simvoldan ibarət olmalıdır."
    static let shortNewPassword = "Yeni şifrə minimum 8 simvoldan ibarət olmalıdır."
    static let passwordsDoNotMatch = "Şifrələr eyni deyil."
    static let emptyCurrentPassword = "Cari şifrəni daxil edin."
    static let samePassword = "Yeni şifrə cari şifrədən fərqli olmalıdır."
    static let invalidResetCode = "Kod 6 rəqəmdən ibarət olmalıdır."
    static let roleNotSelected = "Rol seçilməyib."
    static let emptyGroupName = "Qrup adını daxil edin."
    static let longGroupName = "Qrup adı 20 simvoldan uzun ola bilməz."
    static let courseNotSelected = "Kursu seçin."
    static let endDateNotSelected = "Bitmə tarixini seçin."
    static let invalidEndDate = "Bitmə tarixi başlama tarixindən əvvəl ola bilməz."
    static let emptyAnnouncementTitle = "Elanın başlığını daxil edin."
    static let emptyAnnouncementMessage = "Elanın mətnini daxil edin."
    static let groupNotSelected = "Qrupu seçin."
    static let fileNotSelected = "Excel faylını seçin."
    static let fileNotReadable = "Faylı oxumaq mümkün olmadı."
}
