namespace :translation_center do

  desc "Insert yaml translations in db"
  task :yaml2db => :environment do

    def collect_keys(scope, translations)
      full_keys = []
      translations.to_a.each do |key, translations|
        new_scope = scope.dup << key
        if translations.is_a?(Hash)
          full_keys += collect_keys(new_scope, translations)
        else
          full_keys << new_scope.join('.')
        end
      end
      return full_keys
    end

    # needed for interpolated translations in I18n
    def get_translation_from_hash(key, hash)
      path = key.split('.')
      last_step = hash
      path.each do |step|
        last_step = last_step[step.to_sym]
      end
      last_step
    end

    # prepare translator
    translator = TranslationCenter::Translation.translator.find_or_initialize_by_email(TranslationCenter::CONFIG['yaml_translator_email'])
    translator.save(validate: false) if translator.new_record?

    # Make sure we've loaded the translations
    I18n.backend.send(:init_translations)
    puts "#{I18n.available_locales.size} #{I18n.available_locales.size == 1 ? 'locale' : 'locales'} available: #{I18n.available_locales.join(', ')}"

    # Get all keys from all locales
    all_yamls = I18n.backend.send(:translations)
    all_keys = all_yamls.collect do |check_locale, translations|
      collect_keys([], translations).sort
    end.flatten.uniq
    puts "#{all_keys.size} #{all_keys.size == 1 ? 'unique key' : 'unique keys'} found."

    new_keys = 0
    missing_keys = I18n.available_locales.inject({}) do |memo, lang|
      memo[lang] = 0
      memo
    end

    all_keys.each do |key|
      translation_key = TranslationCenter::TranslationKey.find_or_initialize_by_name(key)
      if translation_key.new_record?
        translation_key.save
        new_keys += 1
      end

      I18n.available_locales.each do |locale|
        I18n.locale = locale
        begin
          translation = TranslationCenter::Translation.find_or_initialize_by_translation_key_id_and_lang_and_user_id(translation_key.id, locale.to_s, translator.id)
          # no_default option to prevent the default translation from being created
          value = I18n.translate(key, raise: true, yaml: true, no_default: true)
          translation.update_attribute(:value, value)
          # accept this yaml translation
          translation.accept if TranslationCenter::CONFIG['yaml2db_translations_accepted']
        rescue I18n::MissingInterpolationArgument
          # if translation needs parameters for interpolation then get the value
          # as a string from the translations hash          
          value = get_translation_from_hash(translation_key.name, all_yamls[locale])
          translation.update_attribute(:value, value)
          translation.accept if TranslationCenter::CONFIG['yaml2db_translations_accepted']
        rescue I18n::MissingTranslationData
          missing_keys[locale] += 1
        end

      end
    end

    puts "found new #{new_keys} key(s)"
    missing_keys.each do |locale, count|
      puts "missing #{count} translation(s) for #{locale}" if count > 0
    end
  end

  desc "Export translations from db to yaml"
  task :db2yaml => :environment do
    # for each locale build a hash for the translations and write to file
    I18n.available_locales.each do |locale|
      result = {}
      I18n.locale = locale
      puts "Started exporting translations in #{locale}"
      TranslationCenter::TranslationKey.translated(locale).each do |key|
        key.add_to_hash(result, locale)
      end
      File.open("config/locales/#{locale.to_s}.yml", 'w') do |file|
        file.write({locale.to_s => result}.ya2yaml)
      end
      puts "Done exporting translations of #{locale} to #{locale.to_s}.yml"
    end 
    
  end

end