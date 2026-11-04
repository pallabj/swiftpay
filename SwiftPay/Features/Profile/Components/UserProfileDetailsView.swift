import SwiftUI

func UserProfileDetailsView(_ user: User) -> some View {
    Group {
        Section {
            VStack(spacing: 12) {
                AsyncImage(url: user.imageUrl.flatMap { URL(string: $0) }) {
                    phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(16)
                            .foregroundStyle(.blue)
                            .background(Color.blue.opacity(0.1))
                    }
                }
                .frame(width: 96, height: 96)
                .clipShape(Circle())
                .accessibilityLabel("\(user.name)'s profile photo")

                Text(user.name)
                    .font(.title2.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .listRowBackground(Color.clear)
        }

        Section("Personal details") {
            LabeledContent("Phone", value: user.phone)
            LabeledContent("Email", value: user.email)
        }
    }
}
