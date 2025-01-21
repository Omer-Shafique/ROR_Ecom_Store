//= require rails-ujs
//= require jquery
import { Turbo } from "@hotwired/turbo-rails"
import Rails from "@rails/ujs";
Rails.start();


document.addEventListener('turbo:frame-load', function() {
    console.log('Turbo Frame Loaded');
  });
  