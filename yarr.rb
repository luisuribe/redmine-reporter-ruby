#!/usr/bin/env ruby
require 'sinatra'
require 'haml'
require 'data_mapper'

configure do
DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, {
  :adapter  => 'postgres',
  :host     => 'localhost',
  :username => 'postgres' ,
  :password => 'h4ckm3',
  :database => 'redmine',
  :encoding => 'ISO-8859-1'
  })
end

# Modelos
class Issue
  include DataMapper::Resource
  storage_names[:legacy] = 'issues'
  property :id, Serial, :field => 'id'
  property :subject,  String, :field => 'subject'
  property :project_id, Integer, :field => 'project_id'
  property :fixed_version_id, Integer, :field => 'fixed_version_id'
  has n, :hours, 'Hour'
end

class Hour
  include DataMapper::Resource
  storage_names[:legacy] = 'time_entries'
  storage_names[:default] = 'time_entries'
  property :issue_id, Integer, :field => 'issue_id'
  property :logged_hours, Integer, :field => 'hours'
  belongs_to :issue, 'Issues'
end

class Project
  include DataMapper::Resource
  storage_names[:legacy] = 'projects'
  property :id, Serial, :field => 'id'
  property :name,  String, :field => 'name'
  property :description,  String, :field => 'description'
  has n, :issues
end

class Version
  include DataMapper::Resource
  storage_names[:legacy] = 'versions'
  property :id, Serial, :field => 'id'
  property :name,  String, :field => 'name'
  property :description,  String, :field => 'description'
  property :project_id, Integer, :field => 'project_id'
  property :status, String, :field => 'status'
  property :effective_date, DateTime, :field => 'effective_date'
end

get '/' do
    @projects = Project.all :order => :name
    haml :index
end

get '/project/:project_id' do
    @project  = Project.get(params[:project_id])
    @versions = Version.all(:project_id => params[:project_id], :status => 'open', :order => 'effective_date')
    @issues   = Issue.all(:project_id => params[:project_id])
    haml :project
end

get '/version' do
    @project  = Project.get(params[:project_id])
    @versions = Version.all(:project_id => params[:project_id], :status => 'open', :order => 'effective_date')
    @issues   = Issue.all(:fixed_version_id => params[:version_id])
    haml :version
end

def project_path( project )
  "/project/#{ project.id }"
end