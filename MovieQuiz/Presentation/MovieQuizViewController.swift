import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)

    func highlightImageBorder(isCorrectAnswer: Bool)

    func showLoadingIndicator()
    func hideLoadingIndicator()

    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    private var presenter: MovieQuizPresenter!
    
    // MARK: - IBOutlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var questionNumberLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var isAnswerProcessing = false
    
    private var alertPresenter = AlertPresenter()
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkAnswer(true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkAnswer(false)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = MovieQuizPresenter(viewController: self)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        let model = AlertModel(
            title: "Произошла ошибка",
            message: message,
            buttonText: "Попробовать снова"
        ) { [weak self] in
            self?.presenter.restartGame()
        }

        alertPresenter.show(in: self, model: model)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = UIImage(data: step.image) ?? UIImage()
        questionLabel.text = step.question
        questionNumberLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        isAnswerProcessing = false
    }

    private func checkAnswer(_ answer: Bool) {
        guard !isAnswerProcessing else { return }
        isAnswerProcessing = true

        let isCorrect: Bool
        if answer {
            isCorrect = presenter.yesButtonClicked()
        } else {
            isCorrect = presenter.noButtonClicked()
        }

        highlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.showNextQuestionOrResults()
        }
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer
            ? UIColor(named: "YP Green")?.cgColor
            : UIColor(named: "YP Red")?.cgColor
        imageView.layer.cornerRadius = 20
    }

    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }

            self.presenter.restartGame()
        }

        alertPresenter.show(in: self, model: model)
    }
}
