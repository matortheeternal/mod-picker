app.directive('sticky', function($timeout) {
    return {
        restrict: 'A',
        scope: {
            stickyType: '@stickyType'
        },
        link: function(scope, element, attrs) {
            var $placeholder, $elem = element[0];
            var placeholderHeight, phTop;
            var fixed = false;
            var stickBottom = scope.stickyType === 'bottom';

            var unstick = function() {
                fixed = false;
                if ($placeholder) $placeholder.remove();
                $elem.classList.remove('sticky');
            };

            var stick = function() {
                fixed = true;
                placeholderHeight = $elem.offsetHeight;
                $placeholder = document.createElement('div');
                $placeholder.style.height = placeholderHeight + 'px';
                $elem.parentElement.appendChild($placeholder);
                $elem.classList.add('sticky');
                phTop = $placeholder.offsetTop;
            };

            var fixHeightDiff = function(heightDiff) {
                if (heightDiff != 0) window.scrollBy(0, -heightDiff);
            };

            var toggleStickyTop = function(scrollPos) {
                var top = $elem.offsetTop;
                if (fixed) {
                    // unfix if we are at or above the top of the element + the
                    // difference in the placeholder and the element's height
                    var heightDiff = placeholderHeight - $elem.offsetHeight;
                    if (scrollPos <= top + heightDiff) {
                        fixHeightDiff(heightDiff);
                        unstick();
                    }
                } else if (scrollPos > top) {
                    stick();
                }
            };

            var toggleStickyBottom = function(scrollPos) {
                scrollPos = scrollPos + window.innerHeight;
                var bottom = $elem.offsetTop + $elem.offsetHeight;
                if (fixed) {
                    // unfix if we are at or below the top of the element
                    if (scrollPos >= phTop) unstick();
                } else if (scrollPos < bottom) {
                    stick();
                }
            };

            var toggleSticky = stickBottom ? toggleStickyBottom : toggleStickyTop;
            window.onscroll = function() {
                toggleSticky(window.scrollY);
            };
            $timeout(function() {
                toggleSticky(window.scrollY);
            });

            // destroy placeholder on the $destroy event
            scope.$on('$destroy', function() {
                if (fixed) unstick();
            });
        }
    }
});