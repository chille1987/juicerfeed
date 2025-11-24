// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "alpine-turbo-drive-adapter"
import Alpine from "alpinejs"

window.Alpine = Alpine;

document.addEventListener("alpine:init", () => {
	Alpine.data("themeSwitcher", () => ({
		theme: "light",
		menuOpen: false,

		init() {
			const storedTheme = window.localStorage.getItem("theme");
			this.theme = storedTheme || "light";
		},

		setTheme(name) {
			this.theme = name;
			window.localStorage.setItem("theme", name)
		},

		isActive(name) {
			return this.theme === name;
		}
	}))
})

Alpine.start();