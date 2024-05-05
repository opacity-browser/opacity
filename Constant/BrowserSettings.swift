//
//  SearchEngineList.swift
//  Opacity
//
//  Created by Falsy on 3/27/24.
//

import SwiftUI

class SearchEngine: Codable {
  var name: String
  var searchUrlString: String
  var favicon: String
  var faviconWhite: String
  
  init(name: String, searchUrlString: String, favicon: String, faviconWhite: String) {
    self.name = name
    self.searchUrlString = searchUrlString
    self.favicon = favicon
    self.faviconWhite = faviconWhite
  }
}

let SCREEN_MODE_LIST: [String] = [
  ScreenModeList.light.rawValue,
  ScreenModeList.dark.rawValue,
  ScreenModeList.system.rawValue
]

let RETENTION_PERIOD_LIST: [String] = [
  DataRententionPeriodList.oneDay.rawValue,
  DataRententionPeriodList.oneWeek.rawValue,
  DataRententionPeriodList.oneMonth.rawValue,
  DataRententionPeriodList.indefinite.rawValue
]

let BLOCKING_TRACKER_LIST: [String] = [
  BlockingTrakerList.blockingStrong.rawValue,
  BlockingTrakerList.blockingModerate.rawValue,
  BlockingTrakerList.blockingLight.rawValue,
  BlockingTrakerList.blockingNone.rawValue
]

let SEARCH_ENGINE_LIST: [SearchEngine] = [
  SearchEngine(name: "Google", searchUrlString: "https://www.google.com/search?q=", favicon: "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", faviconWhite: "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAASHSURBVHgB3ZvJj5RFGMafnmhg1AhE0IyotCwxo3GJmmCEyIGL0YN6U/8ALihqPOoFNUYZvGj0YDR6UNCDUU96IYa4RIlGZzBoIhB0UMM+Q8IyLPPyPFQ3EJjunqqv6tt+yS9NmO7avq3qrfdrICFm1uDHAF1Bb6eL6CCdS2fRma2vTtAxOkr30q30Z/or3dVoNAxVgZ3uoyvoerrdsjFJt9F36HKUGTZwNn0hQqe7sYOuoQMoC62Or6Vjlh8H6RCdj6Jg5Q36TKsxRTFKVyNvWOli+r2VhxHaRGrMHfVVlu/pPl3G6VNIhbnOv27l5hBdhNiw0Bl0o5WbnfQWxMZc57+ycrOZXocUsOANVm7eoJchNuau+VesvJyga5AKFr7a0jNBT5o//9H7EYFGh843+TFMr0YcJukWuon+QkfoHnqk9fd+uqCl5vwr6dIO7dtGH+YCaRdSwQEYtjjosaRp8gLPJqgNC+lrdPcF5X1MYx2UjhXHOPWPmrt/zEZGWMY8+ip9EalhJdebm19n4Xc6iCrChq+zbHxIr0QVYcMH6AELZz2qjLlAQyjvoepYeCRHUZp+VBl2YLm5+JsvpyyPdXhC+lqfT6LDpKgH65JOSPLCXOTVF01Q5qLiKIR9M1ys3pePePT3o+JoGXkXwngXETC3eVIYGoB74c+PPPo7EYeH6GcohiENwJ3wZxPioTNgBophiZ4C8+DPd6gHt2oAboA/f6MeXKMB8F2yaqe2LgMwSwMw0/NHp+kx1IP+PvgziRqhAfA9mpfTaq75L+W4BmAcfuixdS3qwZgG4AD8uQP1YFQD8Af8uQf1YJ8GYAf8WYl6sFVT4RH4s1SBkEixAG2QfI5sKGfoPvizpR0KD4kGrUVJsPBodrNdwF/mj3Z9Mm98ZMXcxslu80dbbOdCYl/CH3X+eRTPczQkW+ybc//iaDxgYWgLrLBdINbdtLDdZbHswoKUCxAaFtdWWO4zQ9Z5hbmQfAjb2+WcvQRaubgfIIzb6NuWf2jrLboQYbx5yf+Yy/jMkv42hJwwlyUairb/BjoV/JJl431LeDmw7KvMbcBmYahbBXMse+qrrssmIsMyB83db7Kgrf/5vSp61rKjLTMlNYTEGy9ujy5NJVsctez0zis290SIlQf8r7k0F++bFX9zk7n0mkMWh+Gp6umUJLUYLpkpZj7OT3Dh9G/hYoqyHYzRfUMxBoXo78b5JKmQiNVUHFbZXmsXc0nRIWuE6dAuV5OYE5aunjZhSdRW/uTo6aD7R8c5Ss/JC3+8kR+Po5p8wtP+iW5fmM4AaNvqC/ogqsXX9FEOwES3L/W8ybQKeIRuQHX4lD7Wq/Pe8Gx42dLfsLKi4Ei6dYm5TNJxKx9q0yrkgbl1+G9WHn6gS5A35s6Gf6w4tG7R1D3WhCloEBRU1XWXJcvUFy3btXKdg7JgLtX2aUv76qzK1uu5hQdju8IGLqOKEoWk303Vab2Irbhl9FM9eRjLXBqeMtGUjKXFjpbIN8JFlZWboHCcFkXapFXa3Z9wu1V6hX4z/T/l6/NnAClW8JiAvZIVAAAAAElFTkSuQmCC"),
  SearchEngine(name: "Bing", searchUrlString: "https://www.bing.com/search?q=", favicon: "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", faviconWhite: "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAQDSURBVHgB7ZttaM1RHMe/Q9MiDyM00UxDQt6ppZkXVkqS8pSWeOOpeWNS9oI3tNeE1cpTinlheaPY1EiGMDPsoWiiSWFeGBnb8f1177Jd9979z/k/nXvvPvXt3O79n/85v9/5nfM//3POBTRQShVSjdRvqoUqQiZBgx+o4fykDlFjkAnQ0F8qPp1UAdKdaOgnYoCqQDpDA/+okblB5SMdoWH9yhm91D6kGxoOGOQE0gkDBwgHYTFZOhfTmAHdPKSHKsjKyvoGCwni+T2V2gVLCWoCswaWEpQDZsNSgnKAtVPloCqmO3AGxqgDkOGMRgAynFEHIBjSpgt4ZgjfK8ZQR6lWqo5aC9tR5rTHuVd5nOseUksQIGGOAaVxvltBSURcouYhAMJ0QEuS38qot3TCFWo+fCRMB9x0cM1W6hmdUKNsWGdU5rQnuF+Txj1+UOe8dkTY84A6jWtzqJ2U7EiVIQyUOYkiIJfqU2bIQDkZLgk1ArhO+JVJDcyQKGimE2bCBTZMha/BHHlU3qYTJsGQ0B3AKLjLpAPmLKNO0gljYYAtL0NX4Y4d1F4YoLsvoGBGB1t6UZL75jF5D3cNIvsPhSzni04m3QJNHZAUVrqbST3cIfsP5dDEpvWAKrjnAKMpRyeDNQ5gFDQyuQd3SBRs0clgRRcYggxmXXCHrw7wFUZBF5OFVCXVBzOK2A0cD+7WrQnSCX2UnCvIpdZR56lOjVvIpGgO/ECZnQ9I+C6gWfZSqoJ67aC8Eqf3HYcUgVEhK0Xv+HEGJXMKGY8SRfA0OCRlHEDjdzMZ7BqC9HOF+I5wPAboOsDvp8D/BUaWxI4j/ug+1AlDje6FQ6yNABo+BZGZ3WFqQpJLpfVjG6YHDrHSATReTpRcoPIcZpHWl/NLg12h1WE+uyZCNHwWVcuPt+Dc+FjaOGA67gLWzANouEx+2qjNcLcDdV/n4tC7gIrsBJ2miuENp3Qu1o2AfniEiiyInuXHp/DGeImaBpkv6GTSdcBneAAN38CkidpDZcMbZHy6CE10HfASLqDhyykZ4GQ/YAG8pZmtfxma6DrgCSKPG21o+JFo/lJ4zydqGwzQXRMsYdKAiOOc5lUmZWkgDVLK1r8DA3QjQFZsXuDf9HMkBg9X+3lCZL+p8YKWA1iQGFSN4REQ2yVU9Ltkb2te8JFaxTpVI0jYDbLl/T7m/XsgulYwoPxHyjlDTUdYsPBNKhy6qfWwAVakSgWH/D/xmNJc8vYdVqhe+c8jajFshBWbSNUqf+hRqfKvVFayUnmLONXxup4VsMLF1HPljjcqFQ5MJoMGbKSuKz0eU9up8QgY32ZoNEaWrldTK6l8ai4iqzzfqQ/UK0TOCjZSTdFJVuD8BdBK5mKGICbUAAAAAElFTkSuQmCC"),
  SearchEngine(name: "Yahoo", searchUrlString: "https://search.yahoo.com/search?p=", favicon: "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", faviconWhite: "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAARVSURBVHgB7ZtZqFVVHMa/Y6ZlloqVYpMmiXWhICgsaCAMMnvSQhCbjOol66GBiF6ih6DAhCSJ4lo2SZFJWNCLkUPeh+ZuiJXZpHTRMg0bnD6/xb6KXM/eZ33Lc653b88PPtblnr2+/5rO2mvttQ/Qpk2b45kaKgLJeUqegcfnlWgAVT7Uo1u6CB53oAqoAabSp0caMQjV4Db4LKvVajtQdtSLY+mzV+oI+aswAh6Ez0r1/rcoO+rFE6Rf6TMDVUAVmU2fjaHhDnqU/SswFz6vaPjvQ9lRL15Gn/3SmMN9yjwCUm59b6n3e1B21IunS3/S5wpUAVXkbvp01/MarA/OU3oy4tmsYfQ3TBRnlJIxRpYtirMz57OH4bOw7n9VsPn0eB4JKN8Selyc4zOFPr9JZ+QVrEP63zD7QxoJgxBc2mPEWFvg9Q59XmxUwI/ocSu8BrifHnNyfCZIu+kzuVEBr6fHKngN8J3hvZnZ/r6ez2P0WRNTwFOkrw3TMJw7EIGuu5IeT+b4nCb9QJ85MeUMAR6lx1ORvm8bnmF4T8rxmUWfLYhFF4+UdhnmYWYd0sAzLFh2GJ7vF3itpM8TcFCGhfSY2cDvHnpcneMzkT7hocfZMBtgMj2WN/DrNrw2SINyfBbRZwVSUMa19Dgrx+dSejyS4zOc3hriIFORgjLOoMfTOT6dhkeo4Kgcn7vosx6pKHNN+skIFu7xJ/XxOJVer71QUJ4N9JmHSI74zmkDQiWdiOcCqe/kNUsajHjqxlNFrlIyCR67pddxNDC7fW03Wnx5n/yrjLyfFJTjXfq8BINaQfCXldyOOHZJEzR6tirfFP29DvHMVr43Ub8MNykZAo8u+cUvgPJQ8Avp8VBvPmfy+1kagYGKCveZUZn1zCa/HiPPcxjIqIC30MNZsIR1/8SC2MOk6czmgV+kbczuOEulG9EfKFB4ZLaVrWFZQdxx0scN8n/A7HFeyxvhcbaGmTnxxjObG2LYJI1FK2F2S/yLzWVTQbzV9FiKVqMgb7C53JsTZxrTuBaJxJ4MLULz+FfK20XehzRuRiJRDaCFxWoln6I5vFdwPHUu0nCXy4dwzgbnozksKPjMetx+GKORiNMAYdj+jqNjjXq/q+Dzf5DGdiQS3QAqePjuOrvEejTaqHQhjS/RHzA7mNjLNHZKwxr4X8M0oh7RNwWmbVEDz0b6r6DHAvQnCngd0xgf6T+a2QovhrBcTp0401DAodI6enxoxgirz1cL/MJGKmy7nWP9uiS9K8xs2D1gZLlBk6jVCL1xwv39TikclQ+Vtkk/Sovl9z2OBcweU29kPGELO2DfRUop2HTpfOP6TvXWflQFeu8S/Cedg6pA/928JagSqtBielyOqqDKnCntMyr/DUqAMwnONa/v3xVaK1Fvnsjs3Z1Ywptkpfg9UmyPTpPGIZ7Xes8YqwH9pe8lKAkNT3CZvWYyHNnP0mL4Qr3/Fdq0aVMGDgDF6YUeb1ez8gAAAABJRU5ErkJggg=="),
  SearchEngine(name: "DuckDuckGo", searchUrlString: "https://duckduckgo.com/?q=", favicon: "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", faviconWhite: "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")
]
