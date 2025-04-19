//
//  WelcomeScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 16/03/2025.
//

import SwiftUI

class WelcomeScreenViewModel: ObservableObject {
    @Published var title: String;
    @Published var description: String;
    @Published var image: String;

    @Service var appCoordinator: AppCoordinatorService
    @Service var localStorage: LocalStorageService

    // Propriedades internas
    private var model: [WelcomeScreenModel] =  [
        WelcomeScreenModel(title: "Cuide da sua saúde de forma leve e interativa!",
                           description: "Transforme o autocuidado em um hábito prazeroso com desafios e recompensas. Monitorar sua saúde nunca foi tão fácil!",
                           image: "lootie-1"),
        WelcomeScreenModel(title: "Acompanhe sua evolução diária",
                    description: "Registre seus níveis de dor e bem-estar ao longo do dia. Visualize seu progresso e tome decisões mais informadas sobre sua saúde.",
                           image: "lootie-2"),
        WelcomeScreenModel(title: "Ganhe pontos e conquiste desafios!",
                    description: "Cada check-in e atividade completada te aproxima de novas recompensas. Torne sua jornada de bem-estar mais motivadora!",
                           image: "lootie-3"),
        WelcomeScreenModel(title: "Registre suas medicações com facilidade",
                    description: "Mantenha controle sobre os remédios que você toma e evite esquecimentos. Registre horários e doses para um acompanhamento mais seguro.",
                           image: "lootie-4")
    ]
    
    private var currentIndex: Int = 0
    private var timer: Timer?
    private var interval: Double = 6.00;


    // Inicialização
    init() {
        self.title = self.model[currentIndex].title
        self.description = self.model[currentIndex].description
        self.image = self.model[currentIndex].image
        
        startInterval()
    }
    
    //Funções
    func next(){
        currentIndex += 1
        if(currentIndex >= model.count) {
            localStorage.saveWelcomeScreenState(hasSeen: true)
            appCoordinator.goToPage(.register)
            return
        }
        
        timer?.invalidate()
        timer = nil
        
        self.title = self.model[currentIndex].title
        self.description = self.model[currentIndex].description
        self.image = self.model[currentIndex].image
        
        startInterval()
    }
    
    func startInterval() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.next()
            }
        }
    }

    // Destruidor
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
}
