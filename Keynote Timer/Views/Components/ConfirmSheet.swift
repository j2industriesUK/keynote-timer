import SwiftUI

struct ConfirmSheet: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let confirmLabel: String
    let onConfirm: () -> Void

    func body(content: Content) -> some View {
        content.confirmationDialog(title, isPresented: $isPresented, titleVisibility: .visible) {
            Button(confirmLabel, role: .destructive, action: onConfirm)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(message)
        }
    }
}

extension View {
    func confirmAction(isPresented: Binding<Bool>, title: String, message: String,
                       confirmLabel: String, onConfirm: @escaping () -> Void) -> some View {
        modifier(ConfirmSheet(isPresented: isPresented, title: title, message: message,
                              confirmLabel: confirmLabel, onConfirm: onConfirm))
    }
}
