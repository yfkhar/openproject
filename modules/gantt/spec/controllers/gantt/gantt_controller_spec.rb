# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2024 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

require "spec_helper"

RSpec.describe Gantt::GanttController do
  shared_let(:project) { create(:project, identifier: "test_project", public: false) }

  current_user do
    create(:user,
           member_with_permissions: { project => %i[view_work_packages export_work_packages] })
  end

  describe "index" do
    let(:default_gantt_params) { Gantt::DefaultQueryGeneratorService.new(with_project: project).call }

    context "for atom format" do
      let(:params) { default_gantt_params.merge(project_id: project.id, format: "atom") }

      it "returns the atom feed" do
        get("index", params:)

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include("application/atom+xml")
      end
    end
  end
end
