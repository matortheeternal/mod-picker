app.directive('sticky', function () {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            var $placeholder, $elem = element[0];
            var placeholderHeight, bottom, top = $elem.getBoundingClientRect().top;
            var fixed = false;

            var toggleSticky = function(scrollPos) {
                if (fixed) {
                    // unfix if we are at or above the top of the element + the different in the placeholder and the element's height
                    var heightDiff = placeholderHeight - $elem.offsetHeight;
                    if (scrollPos <= top + heightDiff) {
                        fixed = false;
                        if ($placeholder) $placeholder.remove();
                        if (heightDiff != 0) window.scrollBy(0, -heightDiff);
                        $elem.classList.remove('sticky');
                    }
                } else if (scrollPos > top) {
                    fixed = true;
                    placeholderHeight = $elem.offsetHeight;
                    $placeholder = document.createElement('div');
                    $placeholder.style.height = placeholderHeight + 'px';
                    $elem.parentElement.appendChild($placeholder);
                    bottom = $placeholder.getBoundingClientRect().bottom;
                    $elem.classList.add('sticky');
                }
            };

            window.onscroll = function() {
                toggleSticky(window.scrollY);
            }
        }
    }
});