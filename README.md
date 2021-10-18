# is-mart-open-api-elixir

[API] 오늘 대형마트 영업하나요? w/ Elixir

## REST API [WIP]

### :warning: 주의

계속 업데이트 중인 문서입니다. 변동 사항이 있을 수 있습니다.

### 마트 검색

- URL

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

### 마트 조회

- URL

  `GET /info/:mart/:name`

- URL Params
  
  - `mart`: 마트 종류 (`emart`, `traders`, `homeplus`, `costco`)
  - `name`: 점포 이름

- Success Response

  ```json
  {
    "close_time": "23:00:00",
    "name": "이마트 경산점",
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
