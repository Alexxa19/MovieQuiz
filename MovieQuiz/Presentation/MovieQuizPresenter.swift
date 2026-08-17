import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let statisticService: StatisticServiceProtocol

    init(
        viewController: MovieQuizViewControllerProtocol,
        questionFactory: QuestionFactoryProtocol,
        statisticService: StatisticServiceProtocol
    ) {
        self.viewController = viewController
        self.questionFactory = questionFactory
        self.statisticService = statisticService

        self.questionFactory?.delegate = self
        questionFactory.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    private var isAnswerProcessing = false
    private var questionFactory: QuestionFactoryProtocol?
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        viewController?.show(quiz: viewModel)
    }
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        isAnswerProcessing = false
        questionFactory?.requestNextQuestion()
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    private func didAnswer(isYes: Bool) {
        guard !isAnswerProcessing else { return }
        guard let currentQuestion = currentQuestion else { return }

        isAnswerProcessing = true

        let isCorrect = isYes == currentQuestion.correctAnswer
        didAnswer(isCorrect: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.isAnswerProcessing = false
            self.showNextQuestionOrResults()
        }
    }

    func showNextQuestionOrResults() {
        if isLastQuestion() {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeResultsMessage(),
                buttonText: "Сыграть ещё раз"
            )
            viewController?.show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }

    func getCorrectAnswers() -> Int {
        return correctAnswers
    }

    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)

        let bestGame = statisticService.bestGame
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

        return [
            currentGameResultLine,
            totalPlaysCountLine,
            bestGameInfoLine,
            averageAccuracyLine
        ].joined(separator: "\n")
    }
}
