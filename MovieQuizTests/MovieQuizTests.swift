import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {
    func testConvertModel() {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader())
        let statisticService = StatisticService()
        let sut = MovieQuizPresenter(
            viewController: viewControllerMock,
            questionFactory: questionFactory,
            statisticService: statisticService
        )
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)

        // When
        let viewModel = sut.convert(model: question)

        // Then
        XCTAssertEqual(viewModel.image, emptyData)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
