import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard (scene as? UIWindowScene) != nil else { return }
        
        guard let viewController = window?.rootViewController as? MovieQuizViewController else {
            return
        }
        
        viewController.loadViewIfNeeded()
        
        let moviesLoader = MoviesLoader()
        let questionFactory = QuestionFactory(moviesLoader: moviesLoader)
        let statisticService = StatisticService()
        let presenter = MovieQuizPresenter(
            viewController: viewController,
            questionFactory: questionFactory,
            statisticService: statisticService
        )
        
        viewController.presenter = presenter
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
