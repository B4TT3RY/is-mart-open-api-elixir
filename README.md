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
  
  - `mart`: 마트 종류 (`emart`, `traders`, `homeplus`, `costco`, `emart_everyday`)
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

  :warning: `emart_everyday`는 지점명이 `지점명:고유번호` 로 출력됩니다.

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
  
  - `mart`: 마트 종류 (`emart`, `traders`, `homeplus`, `costco`, `emart_everyday`)
  - `name`: 점포 이름

  :warning: `emart_everyday`는 `점포 이름` 대신 `점포 고유번호`를 입력해야 합니다.

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
