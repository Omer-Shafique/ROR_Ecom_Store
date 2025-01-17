document.addEventListener('turbo:load', () => {
    const searchInput = document.getElementById('search-input');
  
    if (searchInput) {
      searchInput.addEventListener('input', function() {
        const query = this.value;
  
        // Check if query length is greater than 2 characters
        if (query.length > 2) {  
          fetch(`/products/search?query=${query}`, {
            method: 'GET',
            headers: {
              'Accept': 'text/javascript',  // Expect JavaScript response
              'X-Requested-With': 'XMLHttpRequest',
            }
          })
          .then(response => response.text())
          .then(data => {
            document.getElementById('search-results').innerHTML = data;
          });
        } else {
          document.getElementById('search-results').innerHTML = '';  // Clear results
        }
      });
    }
  });
  