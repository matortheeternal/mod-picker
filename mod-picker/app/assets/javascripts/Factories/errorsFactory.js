app.service('errorsFactory', function() {
    this.errorTypes = function() {
        return [
            {
                group: 0,
                name: "Other Errors",
                acronym: "OE",
                caption: "Other errors that don't fall into the other groups are placed in this group.  \r\nClick for more information.",
                errors: []
            },
            {
                group: 1,
                name: "Identical to Master Records",
                acronym: "ITM",
                caption: "ITMs are dirty edits where a record has been overridden in a plugin file, \r\nbut hasn't been changed.  Click for more information.",
                errors: []
            },
            {
                group: 2,
                name: "Identical to Previous Override Records",
                acronym: "ITPO",
                caption: "ITPOs are dirty edits where a record has been overridden in a plugin file, \r\nbut hasn't been changed relative to the previous override.  Click for \r\nmore information.",
                errors: []
            },
            {
                group: 3,
                name: "Deleted References",
                acronym: "UDR",
                caption: "UDRs are dirty edits where a record has been overridden in a plugin file, \r\nbut hasn't been changed.  Click for more information.",
                errors: []
            },
            {
                group: 4,
                name: "Unexpected Subrecords",
                acronym: "UES",
                caption: "UESs are errors where the data structure of a record is abnormal.  \r\nClick for more information.",
                errors: []
            },
            {
                group: 5,
                name: "Unresolved References",
                acronym: "URR",
                caption: "URRs are errors where a record references a record that doesn't exist.  \r\nClick for more information.",
                errors: []
            },
            {
                group: 6,
                name: "Unexpected References",
                acronym: "UER",
                caption: "UERs are errors where a record references a record in an abnormal fashion. \r\n  Click for more information.",
                errors: []
            }
        ];
    }
});