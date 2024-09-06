### Bowling score Ruby on Rails API application 
---

A bowling game involves players rolling a heavy ball down a lane to knock down ten pins arranged in a triangle.
- The goal is to score points by knocking down pins across ten frames.
- Each frame allows for up to two rolls to knock down all 10 pins.
- If you knock down all 10 pins on the first roll, it's a strike, earning 10 points plus the number of pins knocked down in the next two rolls.
- If you knock down all 10 pins across both rolls, it’s a spare, giving you 10 points plus the pins knocked down in the next roll.
- If fewer than 10 pins are knocked down in a frame, you simply score the sum of those pins.
- In the 10th frame, if you get a strike or a spare, you are awarded additional rolls: two extra rolls for a strike and one extra roll for a spare, allowing a final chance to increase your score.
- A perfect game, achieved by getting a strike in every frame, results in a maximum score of 300.

---

#### Running the application:

Spin the server in terminal:
```bash
rails s
```

You can use postman collection provided in `docs/postman_collection`.

In other case you can use `curl`.

##### Create a game:
```bash
curl -X POST http://localhost:3000/games
```

##### Fetch game:
```bash
curl -X GET http://localhost:3000/games/1
```

##### Fetch list of games:
```bash
curl -X GET http://localhost:3000/games
```

##### Update a game:
```bash
curl -X PATCH http://localhost:3000/games/1 -H "Content-Type: application/json" -d '{"pins_ko": 5}'
```

##### Delete a game:
```bash
curl -X DELETE http://localhost:3000/games/1
```
