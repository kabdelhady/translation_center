module TranslationCenter
  class ApplicationController < ActionController::Base
    before_filter :translation_langs_filters
    before_filter :authenticate_user!

    # defaults
    def translation_langs_filters
      session[:current_filter] ||= 'untranslated'
      session[:lang_from] ||= :en
      session[:lang_to] ||= :en
      I18n.locale = session[:lang_from] || I18n.default_locale
    end

    protected
      def can_admin?
        current_user.can_admin_translations?
      end

  end
end
