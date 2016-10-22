app.service('errorsFactory', function() {
    this.errorTypes = function() {
        return [
            {
                group: 0,
                name: "Other Errors",
                acronym: "OE",
                caption: "Other errors that don't fall into the other groups are placed in this group.",
                benign: true,
                errors: []
            },
            {
                group: 1,
                name: "Identical to Master Records",
                acronym: "ITM",
                caption: "ITMs are dirty edits where a record has been overridden in a plugin file, but hasn't been changed.",
                benign: true,
                errors: []
            },
            {
                group: 2,
                name: "Identical to Previous Override Records",
                acronym: "ITPO",
                caption: "ITPOs are dirty edits where a record has been overridden in a plugin file, but hasn't been changed relative to the previous override.",
                benign: true,
                errors: []
            },
            {
                group: 3,
                name: "Deleted References",
                acronym: "UDR",
                caption: "UDRs are dirty edits where an object reference has been deleted instead of being disabled.",
                errors: []
            },
            {
                group: 4,
                name: "Unexpected Subrecords",
                acronym: "UES",
                caption: "UESs are errors where the data structure of a record is abnormal.",
                errors: []
            },
            {
                group: 5,
                name: "Unresolved References",
                acronym: "URR",
                caption: "URRs are errors where a record references another record that doesn't exist.",
                benign: true,
                errors: []
            },
            {
                group: 6,
                name: "Unexpected References",
                acronym: "UER",
                caption: "UERs are errors where a record references another record in an abnormal fashion.",
                benign: true,
                errors: []
            }
        ];
    }
});