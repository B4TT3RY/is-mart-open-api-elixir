# is-mart-open-api-elixir

[API] 오늘 대형마트 영업하나요? w/ Elixir

## REST API [WIP]

### :warning: 주의

계속 업데이트 중인 문서입니다. 변동 사항이 있을 수 있습니다.

### 지점 목록 조회

- URL

  `GET /search/:mart`

  `GET /search/:mart/:keyword`

- URL Params
  
  - `mart`: 마트 종류 (`emart`, `traders`, `homeplus`, `costco`)
  - `keyword`: 검색할 점포 이름

- Success Response

  ```json
  {
    "result": [
      "경산점",
      "구미점",
      "김천점"
    ]
  }
  ```

- Error Response

  ```json
  { "error": "지원하지 않는 마트 종류입니다." }
  ```

  ```json
  { "error": "검색 결과가 없습니다." }
  ```

### 지점 조회

- URL

  `GET /info/:mart/:name`

- URL Params
  
  - `mart`: 마트 종류 (`emart`, `traders`, `homeplus`, `costco`)
  - `name`: 점포 이름

- Success Response

  ```json
  {
    "close_time": "23:00:00",
    "name": "경산점",
    "next_holiday": "2021-10-27",
    "open_time": "10:00:00",
    "state": "open"
  }
  ```

  - State Type
  
    `open`, `before_open`, `after_closed`, `holiday_closed`

- Error Response

  ```json
  { "error": "지원하지 않는 마트 종류입니다." }
  ```

  ```json
  { "error": "해당 점포가 존재하지 않습니다." }
  ```

### 이마트 에브리데이 지점 목록 조회

- URL

  `GET /search/emarteveryday/:region`

  `GET /search/emarteveryday/:region/:keyword`

- URL Params
  
  - `region`: 지역 (`서울`, `경기`, `인천`, `대전`, `대구`, `광주`, `부산`, `울산`, `강원`, `경남`, `경북`, `전남`, `전북`, `충남`, `충북`, `제주`, `세종`)
  - `keyword`: 검색할 점포 이름

- Success Response

  ```json
  {
    "result": [
      { "가락동": 70 },
      { "가양동": 29 }
    ]
  }
  ```

- Error Response

  ```json
  { "error": "지원하지 않는 마트 종류입니다." }
  ```

  ```json
  { "error": "검색 결과가 없습니다." }
  ```

### 이마트 에브리데이 지점 조회

- URL

  `GET /search/emarteveryday/:id`

- URL Params
  
  - `id`: 지점 고유번호

- Success Response

  ```json
  {
    "close_time": "23:00:00",
    "name": "가락동",
    "next_holiday": "2021-10-24",
    "open_time": "10:00:00",
    "state": "open"
  }
  ```

  - State Type
  
    `open`, `before_open`, `after_closed`, `holiday_closed`

- Error Response

  ```json
  { "error": "지원하지 않는 마트 종류입니다." }
  ```

  ```json
  { "error": "해당 점포가 존재하지 않습니다." }
  ```
