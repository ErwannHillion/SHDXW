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

// Kanban drag & drop hook
const KanbanDrag = {
    mounted() {
        this.el.addEventListener("dragstart", (e) => {
            const card = e.target.closest("[data-todo-id]");
            if (!card) return;
            e.dataTransfer.setData("text/plain", card.dataset.todoId);
            e.dataTransfer.effectAllowed = "move";
            card.classList.add("opacity-40", "scale-95");
            // Highlight all columns
            document.querySelectorAll("[data-kanban-status]").forEach(col => {
                col.classList.add("ring-2", "ring-purple-500/30");
            });
        });

        this.el.addEventListener("dragend", (e) => {
            const card = e.target.closest("[data-todo-id]");
            if (card) card.classList.remove("opacity-40", "scale-95");
            document.querySelectorAll("[data-kanban-status]").forEach(col => {
                col.classList.remove("ring-2", "ring-purple-500/30", "ring-purple-500/60", "bg-purple-500/5");
            });
        });

        // Column events
        this.el.querySelectorAll("[data-kanban-status]").forEach(col => {
            col.addEventListener("dragover", (e) => {
                e.preventDefault();
                e.dataTransfer.dropEffect = "move";
                col.classList.add("ring-purple-500/60", "bg-purple-500/5");
                col.classList.remove("ring-purple-500/30");
            });

            col.addEventListener("dragleave", (e) => {
                if (!col.contains(e.relatedTarget)) {
                    col.classList.remove("ring-purple-500/60", "bg-purple-500/5");
                    col.classList.add("ring-purple-500/30");
                }
            });

            col.addEventListener("drop", (e) => {
                e.preventDefault();
                const todoId = e.dataTransfer.getData("text/plain");
                const newStatus = col.dataset.kanbanStatus;
                if (todoId && newStatus) {
                    this.pushEvent("move_to_status", { id: todoId, status: newStatus });
                }
            });
        });
    }
};

// Pomodoro Timer hook - client-side countdown with server validation
const PomodoroTimer = {
    mounted() {
        this.timerInterval = null;
        this.endTime = null;

        this.handleEvent("start_timer", ({duration_seconds}) => {
            this.endTime = Date.now() + duration_seconds * 1000;
            this.startTicking();
        });

        this.handleEvent("stop_timer", () => {
            this.stopTicking();
        });

        // Resume timer if already active
        const isActive = this.el.dataset.active === "true";
        const remaining = parseInt(this.el.dataset.remaining || "0");
        if (isActive && remaining > 0) {
            this.endTime = Date.now() + remaining * 1000;
            this.startTicking();
        }
    },

    startTicking() {
        if (this.timerInterval) return;

        this.timerInterval = setInterval(() => {
            const remaining = Math.max(0, Math.floor((this.endTime - Date.now()) / 1000));
            const display = this.el.querySelector('#timer-display');
            if (display) {
                const min = Math.floor(remaining / 60);
                const sec = remaining % 60;
                display.textContent = `${String(min).padStart(2, '0')}:${String(sec).padStart(2, '0')}`;
            }

            if (remaining <= 0) {
                this.stopTicking();
                this.pushEvent("timer_complete", {});
            }
        }, 1000);
    },

    stopTicking() {
        if (this.timerInterval) {
            clearInterval(this.timerInterval);
            this.timerInterval = null;
        }
    },

    destroyed() {
        this.stopTicking();
    }
};

// XP Toast notification hook
const XpToast = {
    mounted() {
        this.handleEvent("xp_toast", ({xp, gold, description}) => {
            this.showToast(xp, gold, description);
        });
    },

    showToast(xp, gold, description) {
        const toast = document.createElement('div');
        toast.className = 'fixed top-20 right-4 z-50 animate-slide-in';
        toast.innerHTML = `
            <div class="bg-gradient-to-r from-purple-950/90 to-black/90 border border-purple-500/30 rounded-xl px-4 py-3 shadow-2xl shadow-purple-600/20 backdrop-blur-sm">
                <div class="text-xs text-white/40 mb-1">${description || ''}</div>
                <div class="flex items-center gap-3">
                    ${xp > 0 ? `<span class="text-purple-400 font-bold">+${xp} XP</span>` : ''}
                    ${gold > 0 ? `<span class="text-amber-400 font-bold">+${gold} Or</span>` : ''}
                </div>
            </div>
        `;
        document.body.appendChild(toast);

        setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transition = 'opacity 0.5s';
            setTimeout(() => toast.remove(), 500);
        }, 3000);
    }
};

let Hooks = {
    ScrollEffect: ScrollEffect,
    Draggable: Draggable,
    SnakeGame: SnakeGame,
    ShdxwOS: ShdxwOS,
    WarezGlitch: WarezGlitch,
    Clipboard: Clipboard,
    KanbanDrag: KanbanDrag,
    PomodoroTimer: PomodoroTimer,
    XpToast: XpToast
}

export { Hooks }
