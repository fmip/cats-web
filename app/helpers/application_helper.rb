module ApplicationHelper 
    def is_active_controller(controller_name)
        params[:controller] == controller_name ? "active" : nil
    end

    def is_active_action(action_name)
        params[:action] == action_name ? "active" : nil
    end

    def toastr_method_name(level)
        case level.to_sym
            when :notice then 'info'
            when :alert then 'error'
            else level
        end
    end

    def google_map(center)
        "https://maps.googleapis.com/maps/api/staticmap?center=#{center}&size=300x300&zoom=17"
    end

end
