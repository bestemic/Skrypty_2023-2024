import random
import time

SHIPS = {
    "L": (4, 'Lotniskowiec'),
    "S": (3, 'Szturmowiec'),
    "N": (3, 'Niszczyciel'),
    "F": (2, 'Fregata'),
    "P": (2, 'Pancernik'),
    "K": (1, 'Kuter'),
    "Z": (1, 'Zbiornikowiec'),
    "T": (1, 'Tralowiec'),
}

MISS = "miss"
USED = "used"


class Shoot_Config:

    def __init__(self):
        self.player_hitted = dict(
            L=[], S=[], N=[], F=[], P=[], T=[], Z=[], K=[])
        self.computer_hitted = dict(
            L=[], S=[], N=[], F=[], P=[], T=[], Z=[], K=[])
        self.is_hitted = False
        self.to_shoot = {}


def init(config_save=None):
    global shoot_config
    if config_save is None:
        shoot_config = Shoot_Config()
    else:
        shoot_config = config_save


def add_player_ships(board):
    while True:
        board_blocked = False
        for ship_label, ship_info in SHIPS.items():
            if not can_ship_fit_on_board(board.player_board, ship_info[0]):
                board.print()
                print("Nie ma miejsca na planszy")
                input("Wciśnij ENTER by zresetować")
                board.reset_player()
                board_blocked = True
                break

            while True:
                board.print()
                print(
                    f"\033[93mUstawianie: {ship_info[1]} {ship_info[0]} masztowy\033[0m")
                x, y, direction = get_player_coordinates()
                is_valid = validate_ship_placement(
                    x, y, direction, ship_info[0], board.player_board)

                if is_valid:
                    place_ship(x, y, direction, ship_label, board.player_board)
                    break
                else:
                    print("Nie można wstawić statku w podanym miejscu")
                    input("Wciśnij ENTER by kontynuować")

        if not board_blocked:
            break

    board.print()


def get_player_coordinates():
    translator = dict(a=0, b=1, c=2, d=3, e=4, f=5, g=6, h=7, i=8, j=9)
    while True:
        cords = input(
            "Podaj współrzędne i ułożenie statku \"Y X V|H\": ").lower().split(" ")

        try:
            if len(cords) != 3:
                raise Exception("Niepoprawna ilość argumentów")

            if cords[0] not in translator:
                raise Exception("Niepoprawne dane")
            else:
                cords[0] = translator.get(cords[0])

            if cords[2] not in ["v", "h"]:
                raise Exception("Niepoprawne dane")

            cords[1] = int(cords[1]) - 1

            if cords[1] < 0 or cords[1] > 9:
                raise Exception("Niepoprawne dane")

            return cords[0], cords[1], cords[2]
        except ValueError:
            print("Niepoprawne dane")
        except Exception as exception:
            print(exception)


def generate_player_ships(board):
    generate_ships(board, "player")


def generate_computer_ships(board):
    generate_ships(board, "computer")


def generate_ships(board, side):
    while True:
        board_blocked = False
        board_side = board.player_board if side == "player" else board.computer_board
        for ship_label, ship_info in SHIPS.items():
            if not can_ship_fit_on_board(board_side, ship_info[0]):
                board.reset_player() if side == "player" else board.reset_computer()
                board_blocked = True
                break

            while True:
                x, y, direction = generate_coordinates()
                is_valid = validate_ship_placement(
                    x, y, direction, ship_info[0], board_side)

                if is_valid:
                    place_ship(x, y, direction, ship_label,
                               board_side)
                    break

        if not board_blocked:
            break


def generate_coordinates():
    x = random.randint(0, 9)
    y = random.randint(0, 9)
    direction = random.choice(["v", "h"])

    return x, y, direction


def validate_ship_placement(x, y, direction, ship_length, board):
    if direction == "v":
        if x + ship_length > 10:
            return False
        else:
            for i in range(ship_length):
                if board[x + i][y] != "O":
                    return False
                if x + i > 0 and board[x + i - 1][y] != "O":
                    return False
                if x + i < 9 and board[x + i + 1][y] != "O":
                    return False
                if y > 0:
                    if board[x + i][y - 1] != "O":
                        return False
                    if x + i > 0 and board[x + i - 1][y - 1] != "O":
                        return False
                    if x + i < 9 and board[x + i + 1][y - 1] != "O":
                        return False
                if y < 9:
                    if board[x + i][y + 1] != "O":
                        return False
                    if x + i > 0 and board[x + i - 1][y + 1] != "O":
                        return False
                    if x + i < 9 and board[x + i + 1][y + 1] != "O":
                        return False
    else:
        if y + ship_length > 10:
            return False
        else:
            for i in range(ship_length):
                if board[x][y + i] != "O":
                    return False
                if y + i > 0 and board[x][y + i - 1] != "O":
                    return False
                if y + i < 9 and board[x][y + i + 1] != "O":
                    return False
                if x > 0:
                    if board[x - 1][y + i] != "O":
                        return False
                    if y + i > 0 and board[x - 1][y + i - 1] != "O":
                        return False
                    if y + i < 9 and board[x - 1][y + i + 1] != "O":
                        return False
                if x < 9:
                    if board[x + 1][y + i] != "O":
                        return False
                    if y + i > 0 and board[x + 1][y + i - 1] != "O":
                        return False
                    if y + i < 9 and board[x + 1][y + i + 1] != "O":
                        return False
    return True


def can_ship_fit_on_board(board, ship_length):
    for x in range(10):
        for y in range(10):
            if validate_ship_placement(x, y, "v", ship_length, board) or validate_ship_placement(x, y, "h", ship_length, board):
                return True
    return False


def place_ship(x, y, direction, ship_label, board):
    if direction == 'v':
        for i in range(SHIPS[ship_label][0]):
            board[x + i][y] = ship_label
    else:
        for i in range(SHIPS[ship_label][0]):
            board[x][y + i] = ship_label


def player_move(board):
    while True:
        x, y = get_player_move_coordinates()
        shoot_status = shoot(x, y, board.computer_board)

        if shoot_status == MISS:
            board.print(shoot_config.player_hitted,
                        shoot_config.computer_hitted)
            print("Pudło")
            break
        elif shoot_status == USED:
            board.print(shoot_config.player_hitted,
                        shoot_config.computer_hitted)
            print("Już trafiano w to miejsce")
        else:
            shoot_config.computer_hitted[shoot_status].append((x, y))
            sunk_message = is_sunk(shoot_status, board.computer_board)

            if sunk_message != None:
                mark_around_ship(board.computer_board,
                                 shoot_config.computer_hitted[shoot_status])

            board.print(shoot_config.player_hitted,
                        shoot_config.computer_hitted)
            print(
                f"Trafiono {SHIPS[shoot_status][0]} masztowy {SHIPS[shoot_status][1].lower()}")
            if sunk_message != None:
                print(sunk_message)

            if is_win(board.computer_board):
                return True

    return False


def get_player_move_coordinates():
    translator = dict(a=0, b=1, c=2, d=3, e=4, f=5, g=6, h=7, i=8, j=9)
    while True:
        cords = input(
            "Podaj współrzędne \"Y X\": ").lower().split(" ")

        try:
            if len(cords) != 2:
                raise Exception("Niepoprawna ilość argumentów")

            if cords[0] not in translator:
                raise Exception("Niepoprawne dane")
            else:
                cords[0] = translator.get(cords[0])

            cords[1] = int(cords[1]) - 1

            if cords[1] < 0 or cords[1] > 9:
                raise Exception("Niepoprawne dane")

            return cords[0], cords[1]
        except ValueError:
            print("Niepoprawne dane")
        except Exception as exception:
            print(exception)


def computer_move(board):
    while True:
        x, y = get_computer_move_coordinates()
        shoot_status = shoot(x, y, board.player_board)

        if shoot_status == MISS:
            if shoot_config.is_hitted:
                correct_aim(x, y)
            board.print(shoot_config.player_hitted,
                        shoot_config.computer_hitted)
            print("Komputer spudłował")
            break
        elif shoot_status == USED:
            board.print(shoot_config.player_hitted,
                        shoot_config.computer_hitted)
        else:
            shoot_config.is_hitted = True
            aim(shoot_status, x, y, board.player_board)

            sunk_message = is_sunk(shoot_status, board.player_board)
            if sunk_message != None:
                mark_around_ship(board.player_board,
                                 shoot_config.player_hitted[shoot_status])
                if shoot_status in shoot_config.to_shoot:
                    shoot_config.to_shoot.pop(shoot_status)

            board.print(shoot_config.player_hitted,
                        shoot_config.computer_hitted)
            print(
                f"Komputer trafił {SHIPS[shoot_status][0]} masztowy {SHIPS[shoot_status][1].lower()}")
            time.sleep(2)

            if sunk_message != None:
                print(sunk_message)
                time.sleep(2)

            if is_win(board.player_board):
                return True

    return False


def get_computer_move_coordinates():
    if shoot_config.is_hitted:
        if len(shoot_config.to_shoot) == 0:
            shoot_config.is_hitted = False
        else:
            _, ship_coords = next(iter(shoot_config.to_shoot.items()))
            cords = ship_coords[0]
            ship_coords.remove(cords)
            return cords

    x = random.randint(0, 9)
    y = random.randint(0, 9)
    return x, y


def aim(ship_label, x, y, board):
    if len(shoot_config.player_hitted[ship_label]) == 0 and SHIPS[ship_label][0] != 1:
        to_shoot = []
        max_spaces = find_max_space(x, y, board)

        if max_spaces[0] >= SHIPS[ship_label][0]:
            for i in range(1, SHIPS[ship_label][0]):
                if x - i >= 0 and board[x - i][y] != "X" and board[x - i][y] != "*":
                    to_shoot.append((x - i, y))
                else:
                    break
            for i in range(1, SHIPS[ship_label][0]):
                if x + i <= 9 and board[x + i][y] != "X" and board[x + i][y] != "*":
                    to_shoot.append((x + i, y))
                else:
                    break

        if max_spaces[1] >= SHIPS[ship_label][0]:
            for i in range(1, SHIPS[ship_label][0]):
                if y - i >= 0 and board[x][y - i] != "X" and board[x][y - i] != "*":
                    to_shoot.append((x, y - i))
                else:
                    break
            for i in range(1, SHIPS[ship_label][0]):
                if y + i <= 9 and board[x][y + i] != "X" and board[x][y + i] != "*":
                    to_shoot.append((x, y + i))
                else:
                    break

        shoot_config.to_shoot[ship_label] = to_shoot

    elif len(shoot_config.player_hitted[ship_label]) == 1 and SHIPS[ship_label][0] > 2:
        first_hit = shoot_config.player_hitted[ship_label][0]
        to_shoot = shoot_config.to_shoot[ship_label]

        if first_hit[0] == x:
            for shoot in to_shoot:
                if shoot[0] != x:
                    to_shoot.remove(shoot)
        elif first_hit[1] == y:
            for shoot in to_shoot:
                if shoot[1] != y:
                    to_shoot.remove(shoot)

        shoot_config.to_shoot[ship_label] = to_shoot

    shoot_config.player_hitted[ship_label].append((x, y))


def correct_aim(x, y):
    ship_label, ship_coords = next(iter(shoot_config.to_shoot.items()))
    first_hit = shoot_config.player_hitted[ship_label][0]
    to_shoot = []

    if x == first_hit[0]:
        for point in ship_coords:
            if y < first_hit[1]:
                if not point[1] < y:
                    to_shoot.append(point)
            else:
                if not point[1] > y:
                    to_shoot.append(point)

    if y == first_hit[1]:
        for point in ship_coords:
            if x < first_hit[0]:
                if not point[0] < x:
                    to_shoot.append(point)
            else:
                if not point[0] > x:
                    to_shoot.append(point)

    shoot_config.to_shoot[ship_label] = to_shoot


def find_max_space(x, y, board):
    max_v = 1
    max_h = 1

    for i in range(1, x + 1):
        if board[x - i][y] != "X" and board[x - i][y] != "*":
            max_v += max_v
        else:
            break
    for i in range(1, 10 - x):
        if board[x + i][y] != "X" and board[x + i][y] != "*":
            max_v += max_v
        else:
            break

    for i in range(1, y + 1):
        if board[x][y - i] != "X" and board[x][y - i] != "*":
            max_h += max_h
        else:
            break
    for i in range(1, 10 - y):
        if board[x][y + i] != "X" and board[x][y + i] != "*":
            max_h += max_h
        else:
            break

    return max_v, max_h


def shoot(x, y, board):
    if board[x][y] == "O":
        board[x][y] = "*"
        return MISS
    elif not (board[x][y] == "O" or board[x][y] == "*" or board[x][y] == "X"):
        ship_label = board[x][y]
        board[x][y] = "X"
        return ship_label
    elif board[x][y] == "*" or board[x][y] == "X":
        return USED


def is_sunk(ship_label, board, computer=False):
    sunk = True
    for row in board:
        for cell in row:
            if cell == ship_label:
                sunk = False

    if sunk:
        if computer and SHIPS[ship_label][0] > 1:
            shoot_config.to_shoot.pop(ship_label)
        return f"Zatopiono {SHIPS[ship_label][0]} masztowy {SHIPS[ship_label][1].lower()}"

    return None


def mark_around_ship(board, ship_points):
    directions = [(-1, 0), (1, 0), (0, -1), (0, 1),
                  (-1, -1), (-1, 1), (1, -1), (1, 1)]

    for x, y in ship_points:
        for dx, dy in directions:
            new_x, new_y = x + dx, y + dy
            if 0 <= new_x < 10 and 0 <= new_y < 10 and board[new_x][new_y] == "O":
                board[new_x][new_y] = "*"


def is_win(board):
    for row in board:
        for cell in row:
            if cell in SHIPS:
                return False
    return True
