// MARK: - TopUserCard

struct TopUserCard: View {
    var item: RankingItem
    @EnvironmentObject var appCoordinator: AppCoordinatorService


    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color.green.opacity(0.2)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(appCoordinator.user?.nome ?? item.nickname)
                    .font(.headline)
                    .foregroundColor(.black)
                HStack(spacing: 4) {
                    Text("Posição atual:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("#\(item.position ?? 999999)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    Image(systemName: "arrow.down")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
            }
            Spacer()
            VStack {
                Text(item.rankName.capitalized)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.brown)
                    .cornerRadius(10)
                
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.yellow)
                    Text("\(item.pontuacao)")
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}