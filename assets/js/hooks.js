import ScrollEffect from "./homepage_scroll"

// Draggable window hook
const Draggable = {
    mounted() {
        const el = this.el;
        const titlebar = el.querySelector('.window-titlebar');

        if (!titlebar) return;

        let isDragging = false;
        let startX, startY, initialX, initialY;

        titlebar.addEventListener('mousedown', (e) => {
            if (e.target.tagName === 'BUTTON') return;

            isDragging = true;
            startX = e.clientX;
            startY = e.clientY;
            initialX = el.offsetLeft;
            initialY = el.offsetTop;

            el.style.transition = 'none';
        });

        document.addEventListener('mousemove', (e) => {
            if (!isDragging) return;

            const dx = e.clientX - startX;
            const dy = e.clientY - startY;

            el.style.left = `${initialX + dx}px`;
            el.style.top = `${initialY + dy}px`;
        });

        document.addEventListener('mouseup', () => {
            isDragging = false;
            el.style.transition = '';
        });
    }
};

// Snake game keyboard controls and game loop
const SnakeGame = {
    mounted() {
        this.gameInterval = null;
        this.target = this.el.getAttribute('phx-target');

        this.handleKeyDown = (e) => {
            const directions = {
                'ArrowUp': 'up',
                'ArrowDown': 'down',
                'ArrowLeft': 'left',
                'ArrowRight': 'right'
            };

            if (directions[e.key]) {
                e.preventDefault();
                this.pushEventTo(this.target, 'snake_direction', { direction: directions[e.key] });
            }
        };

        // Focus the element to capture keyboard events
        this.el.focus();
        this.el.addEventListener('keydown', this.handleKeyDown);

        // Also listen on document for better UX
        document.addEventListener('keydown', this.handleKeyDown);

        // Check initial state
        this.checkGameState();
    },

    checkGameState() {
        const running = this.el.dataset.running === 'true';
        const gameOver = this.el.dataset.gameOver === 'true';

        if (running && !gameOver && !this.gameInterval) {
            this.startGameLoop();
        } else if ((!running || gameOver) && this.gameInterval) {
            this.stopGameLoop();
        }
    },

    startGameLoop() {
        if (this.gameInterval) return;

        this.gameInterval = setInterval(() => {
            this.pushEventTo(this.target, 'snake_tick', {});
        }, 120);
    },

    stopGameLoop() {
        if (this.gameInterval) {
            clearInterval(this.gameInterval);
            this.gameInterval = null;
        }
    },

    updated() {
        this.checkGameState();
    },

    destroyed() {
        document.removeEventListener('keydown', this.handleKeyDown);
        this.stopGameLoop();
    }
};

// Main OS hook
const ShdxwOS = {
    mounted() {
        // Handle right-click for minesweeper flags
        this.el.addEventListener('contextmenu', (e) => {
            e.preventDefault();

            // Find the minesweeper cell button
            const btn = e.target.closest('button[phx-click="minesweeper_reveal"]');
            if (btn) {
                const x = btn.getAttribute('phx-value-x');
                const y = btn.getAttribute('phx-value-y');
                const target = btn.getAttribute('phx-target');

                this.pushEventTo(target, 'minesweeper_flag', { x, y });
            }
        });
    }
};

let Hooks = {
    ScrollEffect: ScrollEffect,
    Draggable: Draggable,
    SnakeGame: SnakeGame,
    ShdxwOS: ShdxwOS
}

export { Hooks }
