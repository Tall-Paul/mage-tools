update core_config_data set `value` = 'http://magento.local/' where path = 'web/unsecure/base_url';
update core_config_data set `value` = 'http://magento.local/' where path = 'web/secure/base_url';
update core_config_data set `value` = 'http://magento.local/skin/' where path = 'web/unsecure/base_skin_url';
update core_config_data set `value` = 'http://magento.local/skin/' where path = 'web/secure/base_skin_url';
update core_config_data set `value` = 'http://magento.local/media/' where path = 'web/unsecure/base_media_url';
update core_config_data set `value` = 'http://magento.local/media/' where path = 'web/secure/base_media_url';
update core_config_data set `value` = 'http://magento.local/js/' where path = 'web/unsecure/base_js_url';
update core_config_data set `value` = 'http://magento.local/js/' where path = 'web/secure/base_js_url';
