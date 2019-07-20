class VueGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers

  source_root File.expand_path('../templates', __FILE__)

  attr_accessor :options, :attributes

  # similar create vue file the given location usign the template
  # creates file app/javascript/views/[namespace]/[controller]/action.vue
  def create_vue_file_index
    template "index.erb", "app/javascript/views/#{plural_name}/index.vue"
  end

  def create_vue_file_edit
    template "edit.erb", "app/javascript/views/#{plural_name}/edit.vue"
  end

  def create_vue_file_new
    template "new.erb", "app/javascript/views/#{plural_name}/new.vue"
  end

  def create_vue_file_form
    template "_form.erb", "app/javascript/views/#{plural_name}/_form.vue"
  end

  def create_vue_file_show
    # template "_form.erb", "app/javascript/views/#{plural_name}/_form.vue"
  end

  def create_vuex_modules
    template "modules.js.erb", "app/javascript/packs/vuex/modules/#{plural_name}/#{plural_name}.js"
  end

  # def create_apis
  #   template "api.js.erb", "app/javascript/packs/vuex/api/#{plural_name}/#{plural_name}.js"
  # end

  def create_router_item
    output_path = "app/javascript/packs/router/index.js"
    root_js_file = "#{Rails.root.to_s}/#{output_path}"
    file = File.open(root_js_file, "rb")
    contents = file.read
    
    if contents.include?("#{router_path_index}")
        warn "\e[31mWarning: route path [ #{router_path_index} ] exists!! skip update router/index.js\e[0m"
    else
        template root_js_file, output_path
    end
  end

  def create_menu_item
    output_path = "app/javascript/packs/lib/slideMenuItems_dev.js"
    menu_js_file = "#{Rails.root.to_s}/#{output_path}"
    file = File.open(menu_js_file, "rb")
    contents = file.read
    
    if contents.include?(router_index_name)
        warn "\e[31mWarning: menu item [ #{router_index_name} ] exists!! skip update lib/slideMenuItems_dev.js\e[0m"
    else
        template menu_js_file, output_path
    end
  end

  # # you got this one right?
  # # create or update app/views/[namespace]/[controller]/action.html.erb
  # def create_erb_file
  #   template "html.erb", "app/views/#{name}.html.erb"
  # end

  private
  # Here are some helper methods which are used in the templates
  # they are pretty easy to understand

  # splits the name reports/new
  # ['reports', 'new']
  def parts
    name.split('/')
  end

  # create js file name for reports/new
  # ReportsNew
  def js_file_name
    parts.map {|n| n.downcase.titleize}.join("")
  end

  def vue_component_kebab_name
    [human_name.parameterize, "view"].join("-") 
  end

  def vue_component_snippet
    """
<#{vue_component_kebab_name}>
</#{vue_component_kebab_name}>
"""
  end

  def javascript_pack_tag_snippet
    "<%= javascript_pack_tag '#{name}' %>"
  end

  def stylesheet_pack_tag_snippet
    "<%= stylesheet_pack_tag '#{name}' %>"
  end

  def model_columns_for_attributes
    class_name.constantize.columns.reject do |column|
      column.name.to_s =~ /^(created_by|created_id|created_at|updated_id|updated_by|updated_at|version)$/
    end
  end

  def editable_attributes
    attributes ||= model_columns_for_attributes.map do |column|
      Rails::Generators::GeneratedAttribute.new(column.name.to_s, column.type)
    end
  end

  def all_attributes
    attributes ||= class_name.constantize.columns.map do |column|
      Rails::Generators::GeneratedAttribute.new(column.name.to_s, column.type)
    end
  end


  def input_type(type)
    case type
      when :integer              then :number
      when :float, :decimal      then :text
      when :time                 then :time
      when :datetime, :timestamp then :datetime
      when :date                 then :date
      when :text                 then :textarea
      when :boolean              then :radio
      else
          :text
    end
  end

  def component_form_tag
    "#{human_name.parameterize}-form"
  end

  def form_name
    "#{name}Form"
  end

  def name_plural
    name.pluralize
  end

  def name_singular
    name.singularize
  end

  #for modules
  def fetch_plural_name
    "FETCH_#{plural_underscore.upcase}"
  end

  def get_singular_name
    "GET_#{singular_underscore.upcase}"
  end

  def update_singular_name
    "UPDATE_#{singular_underscore.upcase}"
  end
  
  def delete_singular_name
    "DELETE_#{singular_underscore.upcase}"
  end

  def init_singular_name
    "INIT_#{singular_underscore.upcase}"
  end

  def singular_underscore
    name.singularize.underscore
  end

  def plural_underscore
    name.pluralize.underscore
  end

  # for router
  def base_path
    "/#/"
  end

  def router_path_new
    "#{base_path}#{plural_name}/new"
  end

  def router_path_edit
    "#{base_path}#{plural_name}/:id/edit"
  end

  def router_path_index
    "#{base_path}#{plural_name}/index"
  end

  def router_path_show
    "#{base_path}#{plural_name}/:id/show"
  end

  def import_router_component
    text = <<~EOF
             start of #{name}
            import #{router_index_name} from '../../views/#{plural_name}/index'
            import #{router_edit_name} from '../../views/#{plural_name}/edit'
            import #{router_new_name} from '../../views/#{plural_name}/new'
            //import #{router_show_name} from '../../views/#{plural_name}/show'
            //<%=import_router_component%>
            EOF
  end
  
  def router_index_name
    "#{name}Index"
  end

  def router_new_name
    "#{name}New"
  end

  def router_show_name
    "#{name}Show"
  end

  def router_edit_name
    "#{name}Edit"
  end

  def router_item
    text = <<~EOF
        <%=router_item%>
                // start of #{name}
                {
                    path: '#{router_path_index}',
                    name: '#{router_index_name}',
                    component: #{router_index_name}
                },

                {
                    path: '#{router_path_new}',
                    name: '#{router_new_name}',
                    component: #{router_new_name}
                },

                {
                    path: '#{router_path_edit}',
                    name: '#{router_edit_name}',
                    component: #{router_edit_name}
                },

                //{
                  //  path: '#{router_path_show}',
                  //  name: '#{router_show_name}',
                  //  component: #{router_show_name}
                //},
        EOF
  end


  # for menu
  def menu_item
    text = <<~EOF
        <%=menu_item%>
                    // start of #{name_singular}
                    {
                        type: 'item',
                        icon: 'fa fa-circle-o',
                        name: '#{router_index_name}',
                        router: {
                            name: '#{router_index_name}'
                        }
                    },
        EOF
  end
end
