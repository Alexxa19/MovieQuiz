import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading

    private var questions: [QuizQuestion] = []
    private var currentQuestionIndex = 0

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate? = nil) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    func requestNextQuestion() {
        guard currentQuestionIndex < questions.count else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }

        let question = questions[currentQuestionIndex]
        currentQuestionIndex += 1

        delegate?.didReceiveNextQuestion(question: question)
    }

    func reset() {
        currentQuestionIndex = 0
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let mostPopularMovies):
                    self?.questions = mostPopularMovies.items.map { movie in
                        let imageData = try? Data(contentsOf: movie.resizedImageURL)
                        return QuizQuestion(
                            image: imageData ?? Data(),
                            text: "Рейтинг этого фильма больше чем 6?",
                            correctAnswer: (Double(movie.rating) ?? 0) > 6
                        )
                    }
                    self?.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self?.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
