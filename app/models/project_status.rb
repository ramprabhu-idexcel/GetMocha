class ProjectStatus < HardCodeModel(:id, :name)
  ACTIVE = 1
  ONHOLD = 2
  COMPLETED = 3

  def self.create_all
    create(ACTIVE, "Active")
    create(ONHOLD, "On Hold")
    create(COMPLETED, "Completed")
  end
end
