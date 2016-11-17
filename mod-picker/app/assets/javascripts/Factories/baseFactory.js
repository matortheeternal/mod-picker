app.service('baseFactory', function() {
    this.getModListGroupBase = function() {
        return {
            id: 0,
            _destroy: false,
            index: 0,
            tab: "",
            color: 0,
            name: "",
            description: ""
        }
    };

    this.getModListConfigFileBase = function() {
        return {
            id: 0,
            _destroy: false,
            text_body: "",
            config_file: {
                id: 0,
                filename: "",
                install_path: ""
            }
        }
    };

    this.getCustomConfigFileBase = function() {
        return {
            id: 0,
            _destroy: false,
            filename: "",
            install_path: "",
            text_body: ""
        }
    };

    this.getModListPluginBase = function() {
        return {
            id: 0,
            _destroy: false,
            index: 0,
            group_id: 0,
            merged: false,
            cleaned: false,
            mod: {
                id: 0,
                name: "",
                primary_category_id: 0,
                secondary_category_id: 0
            },
            plugin: {
                id: 0,
                filename: "",
                author: "",
                crc_hash: "",
                file_size: 0,
                errors_count: 0,
                override_count: 0,
                record_count: 0
            }
        }
    };

    this.getCustomPluginBase = function() {
        return {
            id: 0,
            _destroy: false,
            index: 0,
            group_id: 0,
            compatibility_note_id: 0,
            filename: "",
            description: "",
            merged: false,
            cleaned: false
        }
    };

    this.getModListModBase = function() {
        return {
            id: 0,
            _destroy: false,
            index: 0,
            group_id: 0,
            mod: {
                id: 0,
                is_official: false,
                image: "",
                name: "",
                aliases: "",
                authors: "",
                status: "",
                primary_category_id: 0,
                secondary_category_id: 0,
                stars_count: 0,
                asset_files_count: 0,
                average_rating: 0,
                reputation: 0,
                released: "",
                updated: "",
                mod_options: {
                    id: 0,
                    name: "",
                    size: 0,
                    default: false,
                    is_installer_option: false
                }
            },
            mod_list_mod_options: {
                id: 0,
                _destroy: false,
                mod_option_id: 0
            }
        }
    };

    this.getCustomModBase = function() {
        return {
            id: 0,
            _destroy: false,
            index: 0,
            group_id: 0,
            name: "",
            url: "",
            description: "",
            is_utility: false
        }
    };
});