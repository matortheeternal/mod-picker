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

            var toggleStickyTop = function(scrollPos) {
                var top = $elem.offsetTop;
                if (fixed) {
                    // unfix if we are at or above the top of the element + the difference in the placeholder and the element's height
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
                    phTop = $placeholder.offsetTop;
                    $elem.classList.add('sticky');
                }
            };

            var toggleStickyBottom = function(scrollPos) {
                scrollPos = scrollPos + window.innerHeight;
                var bottom = $elem.offsetTop + $elem.offsetHeight;
                if (fixed) {
                    // unfix if we are at or below the top of the element
                    if (scrollPos >= phTop) {
                        fixed = false;
                        if ($placeholder) $placeholder.remove();
                        $elem.classList.remove('sticky');
                    }
                } else if (scrollPos < bottom) {
                    fixed = true;
                    placeholderHeight = $elem.offsetHeight;
                    $placeholder = document.createElement('div');
                    $placeholder.style.height = placeholderHeight + 'px';
                    $elem.parentElement.appendChild($placeholder);
                    phTop = $placeholder.offsetTop;
                    $elem.classList.add('sticky');
                }
            };

            var toggleSticky = stickBottom ? toggleStickyBottom : toggleStickyTop;
            window.onscroll = function() {
                toggleSticky(window.scrollY);
            };
            $timeout(function() {
                toggleSticky(window.scrollY);
            });

        }
    }
});