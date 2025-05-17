//
//  PlayerRouter.swift
//  SonoraPlay
//
//  Created by Aleksandr Shchukin on 15/05/25.
//

import UIKit

final class PlayerRouter: PlayerPresenterToRouterProtocol {
    
    // MARK: - Assembly
    
    static func createModule() -> UIViewController {
        let view = PlayerViewController()
        let presenter = PlayerPresenter()
        let interactor = PlayerInteractor()
        let router = PlayerRouter()
        
        view.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.presenter = presenter
        
        return view
    }
}
