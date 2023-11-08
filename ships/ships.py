#!/usr/bin/python3
# Przemysław Pawlik PJS1

import sys
import os
import pickle
import datetime


SHIPS_TITLE = (
    "\u001B[104m                                   \033[0m\n"
    "\u001B[104m \u001B[107m     \u001B[104m \u001B[107m     \u001B[104m   \u001B[107m  \u001B[104m  \u001B[107m     \u001B[104m \u001B[107m  \u001B[104m \u001B[107m  \u001B[104m \u001B[107m   \u001B[104m \033[0m\n"
    "\u001B[104m \u001B[107m \u001B[104m     \u001B[107m \u001B[104m \u001B[107m \u001B[104m \u001B[107m \u001B[104m  \u001B[107m \u001B[104m \u001B[107m \u001B[104m  \u001B[107m \u001B[104m \u001B[107m \u001B[104m \u001B[107m \u001B[104m  \u001B[107m \u001B[104m \u001B[107m \u001B[104m   \u001B[107m \u001B[104m  \033[0m\n"
    "\u001B[104m \u001B[107m     \u001B[104m   \u001B[107m \u001B[104m    \u001B[107m \u001B[104m \u001B[107m \u001B[104m    \u001B[107m \u001B[104m    \u001B[107m  \u001B[104m    \u001B[107m \u001B[104m  \033[0m\n"
    "\u001B[104m     \u001B[107m \u001B[104m   \u001B[107m \u001B[104m    \u001B[107m   \u001B[104m    \u001B[107m \u001B[104m    \u001B[107m \u001B[104m \u001B[107m \u001B[104m   \u001B[107m \u001B[104m  \033[0m\n"
    "\u001B[104m \u001B[107m     \u001B[104m  \u001B[107m   \u001B[104m  \u001B[107m  \u001B[104m \u001B[107m  \u001B[104m  \u001B[107m   \u001B[104m  \u001B[107m  \u001B[104m \u001B[107m  \u001B[104m \u001B[107m   \u001B[104m \033[0m\n"
    "\u001B[104m                                   \033[0m"
)


class Board:
    BOARD_TITLES = "             \033[04mP L A Y E R B O A R D\033[0m                                 \033[04mC O M P U T E R B O A R D\033[0m\n"
    LABELS = "ABCDEFGHIJ"
    COLORS = {
        'L': '\033[41m',
        'S': '\033[42m',
        'N': '\033[43m',
        'F': '\033[45m',
        'P': '\033[46m',
        'T': '\033[47m',
        'Z': '\033[100m',
        'K': '\033[105m',
    }
    RESET = '\033[0m'
    BLACK = '\033[30m'

    def __init__(self):
        self.player_board = [['O'] * 10 for _ in range(10)]
        self.computer_board = [['O'] * 10 for _ in range(10)]

    def reset_player(self):
        self.player_board = [['O'] * 10 for _ in range(10)]

    def reset_computer(self):
        self.computer_board = [['O'] * 10 for _ in range(10)]

    def print(self, player_hitted=None, computer_hitted=None):
        clear_screen()
        print(self.BOARD_TITLES)

        for i in range(10):
            if i != 0:
                print(f"  {i + 1}", end=' ')
            else:
                print(f"     {i + 1}", end=' ')
        print("           ", end='')
        for i in range(10):
            if i != 0:
                print(f"  {i + 1}", end=' ')
            else:
                print(f"     {i + 1}", end=' ')
        print()
        print("   -----------------------------------------              -----------------------------------------")

        for i in range(10):
            print(f" {self.LABELS[i]}", end=' |')
            for j in range(10):
                player_point = self.player_board[i][j]
                if player_point == 'X':
                    print(
                        f"{self.find_hitted_point_color(i, j, player_hitted)}{self.BLACK} X {self.RESET}", end="|")
                elif player_point == 'O':
                    print("   ", end="|")
                elif player_point == '*':
                    print(" * ", end="|")
                else:
                    print(
                        f"{self.COLORS.get(player_point, '')}{self.BLACK} {player_point} {self.RESET}", end="|")

            print("           ", end="")

            print(f" {self.LABELS[i]}", end=' |')
            for j in range(10):
                computer_point = self.computer_board[i][j]
                if computer_point == 'X':
                    print(
                        f"{self.find_hitted_point_color(i, j, computer_hitted)}{self.BLACK} X {self.RESET}", end="|")
                elif computer_point == '*':
                    print(" * ", end="|")
                else:
                    print("   ", end="|")

            print()
            print("   -----------------------------------------              -----------------------------------------")

    def find_hitted_point_color(self, x, y, hitted):
        for hit in hitted.keys():
            for point in hitted[hit]:
                if point == (x, y):
                    return self.COLORS[hit]


def is_terminal_size_vaid():
    columns, rows = os.get_terminal_size()
    return rows >= 35 and columns >= 105


def load_save(file_name=None, from_cmd=False):
    if file_name is None:
        file_name = input("Podaj nazwę pliku z zapisem: ")

    while True:
        if not file_name.endswith(".pkl"):
            print(f"Nieodpowiedni plik. Wymagany plik z rozszerzeniem .pkl")
            file_name = input(f"Podaj ponownie nazwę pliku lub wciśnij ENTER by wrócić do menu: ")
            if file_name == '':
                menu()
                break
            else:
                continue

        if not os.path.exists(file_name):
            print(f"Plik {file_name} nie został znaleziony.")
            if from_cmd:
                exit(1)
            else:
                file_name = input(f"Podaj ponownie nazwę pliku lub wciśnij ENTER by wrócić do menu: ")
                if file_name == '':
                    menu()
                    break
                else:
                    continue

        try:
            with open(file_name, 'rb') as file:
                board_save, config_save = pickle.load(file)
                game(board_save=board_save, config_save=config_save)
        except Exception as e:
            print("Nie udało się załadować pliku")
            if from_cmd:
                exit(1)
            else:
                file_name = input(f"Podaj ponownie nazwę pliku lub wciśnij ENTER by wrócić do menu: ")
                if file_name == '':
                    menu()
                    break
                else:
                    continue


def clear_screen():
    print('\033[2J\033[0;0H')


def menu():
    clear_screen()

    print(SHIPS_TITLE)
    print("\033[0m")
    print("===================================")
    print("=              MENU               =")
    print("===================================\n")
    print("1. Start gry")
    print("2. Start gry z wygenerowaną planszą")
    print("3. Wczytywanie zapisu")
    print("4. Instrukcje")
    print("5. Wyjście z gry\n")
    print("===================================\n")

    while True:
        option = input("Podaj numer opcji do wykonania: ")
        if option == "1":
            game()
            break
        elif option == "2":
            game(generate=True)
            break
        elif option == "3":
            load_save()
            break
        elif option == "4":
            instructions()
            break
        elif option == "5":
            exit(0)
        else:
            print("Nie ma takiej opcji!")


def game(generate=False, board_save=None, config_save=None):
    clear_screen()

    try:
        import logic
    except:
        print("Nie udało się znaleźć modułu logic")
        exit(1)

    if board_save is None:
        board = Board()
        logic.init()
        logic.generate_computer_ships(board)

        if generate:
            logic.generate_player_ships(board)
        else:
            logic.add_player_ships(board)

        board.print()
        player_move = False
    else:
        board = board_save
        logic.init(config_save)
        board.print(config_save.player_hitted, config_save.computer_hitted)
        player_move = True

    while True:
        if not player_move:
            if logic.player_move(board):
                print("\u001B[93mGratulacje! Wygrałeś!\033[0m")
                break
            decision = input("Wciśnij ENTER by zakończyć turę lub wpisz EXIT by wyjść z programu: ")

            if decision.upper() == 'EXIT':
                clear_screen()

                decision = input("Zapisać grę? Y/N: ")
                if decision.upper() in ['Y', 'YES']:
                    file_name = f"save_{datetime.datetime.now().strftime('%y%m%d%H%M%S')}"
                    decision = input(f"Nazwa zapisu to [{file_name}], wciśnij ENTER by kontynuować lub podaj własną nazwę: ")
                    file_name = file_name if decision == "" else decision
                    with open(f"{file_name}.pkl", 'wb') as file:
                        pickle.dump([board, logic.shoot_config], file)

                print("Dziękujemy za grę.")
                exit(0)

        if logic.computer_move(board):
            print("\u001B[93mPorażka. Komputer wygrał.\033[0m")
            break
        player_move = False

    input("Wciśnij ENTER aby kontynuować ")
    menu()


def instructions():
    clear_screen()

    print("=================================================")
    print("=                  INSTRUKCJE                   =")
    print("=================================================\n")
    show_help("./ships.py")
    print("=================================================\n")

    input("Wciśnij ENTER aby kontynuować ")
    menu()


def show_help(script_name):
    print("Gra w statki - skrypt konsolowy do gry w statki przeciwko komputerowi.\n")

    print("OPIS")
    print("         Ten skrypt pozwala na grę w klasyczną grę w statki z komputerem jako przeciwnikiem.")
    print("         Do działania nie wymaga podawania argumentów, jego domyślną akcją jest uruchomienie menu wyboru.")
    print("         Użycie dodatkowych opcji 'game' pozwala na pominięcie menu wyboru, a połączenie z opcją 'auto'")
    print("         uruchamia grę z ustawionymi statkami gracza. Połączenie opcji 'game' z opcją 'save' pozwala na")
    print("         wczytanie zapisu z pliku.")
    print("         W trakcie gry widoczne są dwie plansze (początkowo domyślnie puste) o wymiarach 10 x 10 pól,")
    print("         wiersze oznaczone są A-J a kolumny 1-10. Lewa plansza wskazuje stronę gracza na której gracz")
    print("         ustawia swoje statki a następnie może obserwować ataki komputera. Prawa natomiast jest stroną")
    print("         komputera i obserwować możemy tam nasze strzały a także trafienia. Statki oznaczone są kolorami")
    print("         i pierwszymi literami ich nazw. Gwiazdka oznacza pudło a 'X' na statku oznacza trafienie.")
    print("         Statki nie mogą się stykać bokami ani rogami. Statki należy ustawić podająć współrzędne początku")
    print("         i kierunek w który dany statek ma być zwrócony. Pierwsza współrzędna to wiersz, druga kolumna, a")
    print("         ułożenie oznaczamy przez 'v' - pionowo, 'h' - poziomo. Przykłady:")
    print("             Dodanie statku mającego początek w A7 i ustawienie go pionowo - A 7 V")
    print("             Dodanie statku mającego początek w C4 i ustawienie go poziomo - C 4 H")
    print("         Aby strzelać należy podać współrzędne celu. Pierwsza to wiersz, druga kolumna. Przykłady:")
    print("             Trafienie w pole H3 - H 3")
    print("             Trafienie w pole A10 - A 10")
    print("         Argumenty podawane przy ustawianiu i strzelaniu muszą być oddzielone pojedynczą spacją.")
    print("         Z programu można wyjść po każdej turze gracza podejąc 'EXIT'. Skrypt pozwala też w tym momencie na")
    print("         zapis stanu gry. Domyślna nazwa zapisu to obecny czas poprzedzony prefixem save_. Można podać własną")
    print("         nazwę. Aby wczytać zapis bezpośrednio po opcji 'save' należy podać plik .pkl z zapisem. Menu również")
    print("         pozwala na wczytanie zapisu.")
    print("         Minimalny rozmiar konsoli to 105 kolumn i 35 wierszy")
    print()

    print("UŻYCIE")
    print(f"         {script_name} [OPCJE] [PLIK]")
    print()

    print("OPCJE")
    print("         -h, --help      wyświetla pomoc")
    print("         -g, --game      uruchamia grę pomijając menu")
    print("         -s, --save      wczytuje zapis, wymaga podania jako kolejnego argumentu nazwy z zapisem,")
    print("                         wymagane użycie z opcję -g lub --game")
    print("         -a, --auto      automatycznie ustawia statki gracza, wymagane użycie z opcję -g lub --game,")
    print("                         ignorowane przy pojawieniu się flagi -s lub --save")
    print()


if __name__ == "__main__":
    if '-h' in sys.argv or '--help' in sys.argv:
        show_help(sys.argv[0])
        exit(0)

    if (not is_terminal_size_vaid()):
        print("Terminal ma niewystarczające wymiary.")
        print("Minimalny wymiar to 105 kolumn na 35 wierszy.")
        exit(1)

    try:
        if '-g' in sys.argv or '--game' in sys.argv:
            if '-s' in sys.argv or '--save' in sys.argv:
                save_index = sys.argv.index('-s' if '-s' in sys.argv else '--save')
                if save_index + 1 < len(sys.argv):
                    save_file = sys.argv[save_index + 1]
                    if save_file.endswith(".pkl"):
                        load_save(save_file, True)
                    else:
                        print(f"Nieodpowiedni plik. Wymagany plik z rozszerzeniem .pkl")
                        exit(1)
                else:
                    print(f"Brak nazwy pliku po {sys.argv[save_index]}.")
                    exit(1)

            if '-a' in sys.argv or '--auto' in sys.argv:
                game(generate=True)
            else:
                game()
        else:
            menu()
    except KeyboardInterrupt:
        clear_screen()
        print(f"Nastąpiło przerwanie skryptu {sys.argv[0]}.")
