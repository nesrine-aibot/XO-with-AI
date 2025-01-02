from flask import Flask, request, jsonify
from flask_cors import CORS  # Add this import

app = Flask(__name__)
CORS(app)  # Enable CORS on all routes

def minimax(board, depth, is_maximizing):
    # Define possible winning combinations
    possible_wins = [
        ['0x0', '0x1', '0x2'],
        ['1x0', '1x1', '1x2'],
        ['2x0', '2x1', '2x2'],
        ['0x0', '1x0', '2x0'],
        ['0x1', '1x1', '2x1'],
        ['0x2', '1x2', '2x2'],
        ['0x0', '1x1', '2x2'],
        ['0x2', '1x1', '2x0'],
    ]

    def check_win(b, player):
        for line in possible_wins:
            if all(b[cell] == player for cell in line):
                return True
        return False

    # Base cases
    if check_win(board, 'O'):
        return 1
    elif check_win(board, 'X'):
        return -1
    elif all(board[key] != '' for key in board):
        return 0  # Draw

    if is_maximizing:
        best_score = float('-inf')
        for key in board:
            if board[key] == '':
                board[key] = 'O'
                score = minimax(board, depth + 1, False)
                board[key] = ''
                best_score = max(score, best_score)
        return best_score
    else:
        best_score = float('inf')
        for key in board:
            if board[key] == '':
                board[key] = 'X'
                score = minimax(board, depth + 1, True)
                board[key] = ''
                best_score = min(score, best_score)
        return best_score

@app.route('/move', methods=['POST'])
def best_move():
    board = request.json['board']
    best_score = float('-inf')
    move = None
    for key in board:
        if board[key] == '':
            board[key] = 'O'
            score = minimax(board, 0, False)
            board[key] = ''
            if score > best_score:
                best_score = score
                move = key
    return jsonify({'move': move})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
