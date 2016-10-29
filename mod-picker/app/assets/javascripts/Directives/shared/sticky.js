app.directive('sticky', function($timeout) {
    return {
        restrict: 'A',
        scope: {
            stickyType: '@stickyType'
        },
        link: function(scope, element, attrs) {
            var $placeholder, $elem = element[0];
            var placeholderHeight, phBottom, top;
            var fixed = false;
            var stickBottom = scope.stickyType === 'bottom';

            $timeout(function() {
                top = $elem.getBoundingClientRect().top;
            });

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
            };

            var fixHeightDiff = function(heightDiff) {
                if (heightDiff != 0) window.scrollBy(0, -heightDiff);
            };

            var toggleStickyTop = function(scrollPos) {
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
                    if (scrollPos >= phBottom) unstick();
                } else if (scrollPos < bottom) {
                    stick();
                    phBottom = bottom;
                }
            };

            var toggleSticky = stickBottom ? toggleStickyBottom : toggleStickyTop;
            var onScrollEvent = function() {
                toggleSticky(window.scrollY);
            };
            window.addEventListener('scroll', onScrollEvent);
            $timeout(function() {
                toggleSticky(window.scrollY);
            });

            // destroy placeholder on the $destroy event
            scope.$on('$destroy', function() {
                if (fixed) unstick();
                window.removeEventListener('scroll', onScrollEvent);
            });
        }
    }
});