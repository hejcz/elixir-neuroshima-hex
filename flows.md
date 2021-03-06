# Document summarizing flows on the website

Assumptions
1. There is no authorization. Visitor without cookie receives one with random identifier. Then they specify nickname joining specific game.
2. User can't run multiple games.
3. There is no mechanism to protect games with a password.

## New visitor
A new visitor receives player id in `AssignPlayerIdIfMissing` plug.

## Joining game
Game is based on channels which **don't have access to user session**. Phoenix supports token based approach in which token is generated by controller, passed to browser rendering html and then passed by socket. It contains game id, user id and game type (so socket can verify if user joins proper room).

## Rejoining game
User who previously joined the game should be redirected to this game automatically. Game type and id are stored in session. When user accesses any endpoint he is redirected to his game endpoint. If game's pid points dead process user has his game-related session info cleared and is redirected to main page.  

## Clearing cookies
User who deletes cookies is handled as a new visitor. There must be some mechanism to remove inactive players and some "break" mechanism where player can agree to increase inactivity treshold for their game.
