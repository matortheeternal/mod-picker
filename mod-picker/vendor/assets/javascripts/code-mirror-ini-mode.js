CodeMirror.defineSimpleMode("ini", {
    // The start state contains the rules that are intially used
    start: [
        {regex: /\/\/.*/, token: "comment"},
        {regex: /\#.*/, token: "comment"},
        {regex: /\;.*/, token: "comment"},
        {regex: /\[[^\]]+\]/, token: "keyword"},
        {regex: /[^\=]+/, token: "def", next: "property"}
    ],
    property: [
        {regex: /\=/, next: "property"},
        {regex: /true|false/i, token: "atom", next: "start"},
        {regex: /[-+]?(?:\.\d+|\d+\.?\d*)/i, token: "number", next: "start"},
        {regex: /.*/, token: "string", next: "start"}
    ]
});