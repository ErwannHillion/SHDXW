const ScrollEffect = {
    mounted() {
        this.windowHeight = window.innerHeight + 550;

        this.handleScroll = () => {
            let scrollPosition = window.scrollY;
            let sections = document.querySelectorAll('.scroll-section');
            let contents = document.querySelectorAll('.scroll-content');
            let lastIndex = sections.length - 1;

            sections.forEach((section, index) => {
                if (scrollPosition >= (index * this.windowHeight) && scrollPosition < ((index + 1) * this.windowHeight)) {
                    contents[index].classList.add('active');
                    sections[index].classList.add('active');
                } else {
                    if (index !== lastIndex) {
                        contents[index].classList.remove('active');
                        sections[index].classList.remove('active');
                    }
                }
            });

            // Garde la dernière section active
            if (scrollPosition > (lastIndex * this.windowHeight)) {
                contents[lastIndex].classList.add('active');
                sections[lastIndex].classList.add('active');
            } else {
                contents[lastIndex].classList.remove('active');
                sections[lastIndex].classList.remove('active');
            }
        };

        window.addEventListener("scroll", this.handleScroll);
    },

    destroyed() {
        window.removeEventListener("scroll", this.handleScroll);
    }
};

export default ScrollEffect;