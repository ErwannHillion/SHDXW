import ScrollEffect from "./homepage_scroll"

// Draggable window hook
const Draggable = {
    mounted() {
        this.state = {
            isDragging: false,
            startX: 0,
            startY: 0,
            initialX: 0,
            initialY: 0
        };

        const el = this.el;
        const windowId = el.id;

        this.handleMouseDown = (e) => {
            // Ignore if clicking on buttons
            if (e.target.tagName === 'BUTTON' || e.target.closest('button')) return;

            // Only drag from titlebar
            const titlebar = e.target.closest('.window-titlebar');
            if (!titlebar) return;

            e.preventDefault();

            // Focus the window via the component
            const componentId = el.dataset.componentId;
            if (componentId && windowId) {
                this.pushEventTo(`#${componentId}`, 'focus_window', { 'window-id': windowId });
            }

            this.state.isDragging = true;
            this.state.startX = e.clientX;
            this.state.startY = e.clientY;
            this.state.initialX = el.offsetLeft;
            this.state.initialY = el.offsetTop;

            el.style.transition = 'none';
            document.body.style.cursor = 'grabbing';
            document.body.style.userSelect = 'none';
        };

        this.handleMouseMove = (e) => {
            if (!this.state.isDragging) return;

            const dx = e.clientX - this.state.startX;
            const dy = e.clientY - this.state.startY;

            el.style.left = `${this.state.initialX + dx}px`;
            el.style.top = `${this.state.initialY + dy}px`;
        };

        this.handleMouseUp = () => {
            if (this.state.isDragging) {
                this.state.isDragging = false;
                el.style.transition = '';
                document.body.style.cursor = '';
                document.body.style.userSelect = '';
            }
        };

        // Attach listeners
        el.addEventListener('mousedown', this.handleMouseDown);
        document.addEventListener('mousemove', this.handleMouseMove);
        document.addEventListener('mouseup', this.handleMouseUp);
    },

    destroyed() {
        document.removeEventListener('mousemove', this.handleMouseMove);
        document.removeEventListener('mouseup', this.handleMouseUp);
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

// Warez glitch effect hook
const WarezGlitch = {
    mounted() {
        const componentId = this.el.dataset.componentId;
        const windowId = this.el.dataset.windowId;

        // End glitch after 2 seconds
        this.glitchTimer = setTimeout(() => {
            this.pushEventTo(`#${componentId}`, 'warez_glitch_done', { 'window-id': windowId });
        }, 2000);
    },

    destroyed() {
        if (this.glitchTimer) {
            clearTimeout(this.glitchTimer);
        }
    }
};

// Clipboard copy hook
const Clipboard = {
    mounted() {
        this.handleEvent("clipboard", ({ text }) => {
            navigator.clipboard.writeText(text);
        });
    }
};

let Hooks = {
    ScrollEffect: ScrollEffect,
    Draggable: Draggable,
    SnakeGame: SnakeGame,
    ShdxwOS: ShdxwOS,
    WarezGlitch: WarezGlitch,
    Clipboard: Clipboard
}

export { Hooks }
