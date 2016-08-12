app.directive('sticky', function () {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            var $elem = element[0];
            var top = $elem.getBoundingClientRect().top;
            var fixed = false;

            var toggleSticky = function(scrollPos) {
                if (fixed) {
                    // unfix if we are at or above the top of the element
                    if (scrollPos <= top) {
                        fixed = false;
                        $elem.classList.remove('sticky');
                    }
                } else if (scrollPos > top) {
                    fixed = true;
                    $elem.classList.add('sticky');
                }
            };

            window.onscroll = function() {
                toggleSticky(window.scrollY);
            }
        }
    }
});