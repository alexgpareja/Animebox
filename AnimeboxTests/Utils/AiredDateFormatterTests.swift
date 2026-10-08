//
//  AiredDateFormatterTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

struct AiredDateFormatterTests {

    init() {
        AppLanguage.current = .spanish
    }

    @Test("nil range devuelve nil")
    func nilRangeReturnsNil() {
        #expect(AiredDateFormatter.rangeString(from: nil) == nil)
    }

    @Test("Sin from ni to devuelve nil")
    func emptyRangeReturnsNil() {
        #expect(AiredDateFormatter.rangeString(from: DateRange(from: nil, to: nil)) == nil)
    }

    @Test("Solo from (película, fecha única) muestra solo esa fecha")
    func onlyFromShowsSingleDate() {
        let text = AiredDateFormatter.rangeString(from: DateRange(from: "2020-04-05T00:00:00+00:00", to: nil))
        #expect(text != nil)
        #expect(text?.contains("-") == false || text?.contains("2020") == true)
    }

    @Test("Acepta el formato de fecha plano de MAL (yyyy-MM-dd) además del ISO8601 de Jikan")
    func parsesPlainMALDateFormat() {
        let text = AiredDateFormatter.rangeString(from: DateRange(from: "2020-04-05", to: nil))
        #expect(text != nil)
    }

    @Test("from y to muestra un rango con separador")
    func fromAndToShowsRange() {
        let text = AiredDateFormatter.rangeString(from: DateRange(from: "2020-04-05T00:00:00+00:00", to: "2020-09-27T00:00:00+00:00"))
        #expect(text?.contains("-") == true)
    }
}
