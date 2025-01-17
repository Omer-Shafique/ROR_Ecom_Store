document.addEventListener("DOMContentLoaded", function () {
    var stripe = Stripe('<%= Rails.configuration.stripe[:publishable_key] %>');
    var elements = stripe.elements();
  
    var style = {
      base: {
        fontSize: "16px",
        color: "#32325d",
        fontFamily: "'Helvetica Neue', Helvetica, sans-serif",
        "::placeholder": { color: "#aab7c4" }
      },
      invalid: { color: "#fa755a", iconColor: "#fa755a" }
    };
  
    var card = elements.create("card", { style: style });
    card.mount("#card-element");
  
    var form = document.querySelector("form");
    form.addEventListener("submit", function (event) {
      event.preventDefault();
      if (!form.checkValidity()) {
        alert("Please fill out all fields correctly.");
        return;
      }
  
      stripe.createToken(card).then(function (result) {
        if (result.error) {
          var errorElement = document.getElementById("card-errors");
          errorElement.textContent = result.error.message;
        } else {
          stripeTokenHandler(result.token);
        }
      });
    });
  
    function stripeTokenHandler(token) {
      var form = document.querySelector("form");
      ["name", "email", "address", "phone"].forEach((field) => {
        var hiddenInput = document.createElement("input");
        hiddenInput.setAttribute("type", "hidden");
        hiddenInput.setAttribute("name", field);
        hiddenInput.setAttribute("value", document.querySelector(`[name="${field}"]`).value);
        form.appendChild(hiddenInput);
      });
  
      form.submit();
    }
  });
  