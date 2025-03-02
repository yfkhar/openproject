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

module Storages
  module Peripherals
    module StorageInteraction
      module OneDrive
        class DownloadLinkQuery
          Auth = ::Storages::Peripherals::StorageInteraction::Authentication

          def self.call(storage:, auth_strategy:, file_link:)
            new(storage).call(auth_strategy:, file_link:)
          end

          def initialize(storage)
            @storage = storage
          end

          def call(auth_strategy:, file_link:)
            if file_link.nil?
              return failure(code: :error, payload: nil, log_message: "File link can not be nil.")
            end

            Auth[auth_strategy].call(storage: @storage) do |http|
              handle_errors http.get(Util.join_uri_path(@storage.uri, uri_path_for(file_link.origin_id)))
            end
          end

          private

          def handle_errors(response)
            case response
            in { status: 300..399 }
              ServiceResult.success(result: response.headers["Location"])
            in { status: 404 }
              failure(code: :not_found,
                      payload: response.json(symbolize_keys: true),
                      log_message: "Outbound request destination not found!")
            in { status: 403 }
              failure(code: :forbidden,
                      payload: response.json(symbolize_keys: true),
                      log_message: "Outbound request forbidden!")
            in { status: 401 }
              failure(code: :unauthorized,
                      payload: response.json(symbolize_keys: true),
                      log_message: "Outbound request not authorized!")
            else
              failure(code: :error,
                      payload: response.json(symbolize_keys: true),
                      log_message: "Outbound request failed with unknown error!")
            end
          end

          def uri_path_for(file_id)
            "/v1.0/drives/#{@storage.drive_id}/items/#{file_id}/content"
          end

          def failure(code:, payload:, log_message:)
            ServiceResult.failure(
              result: code,
              errors: ::Storages::StorageError.new(code:,
                                                   data: StorageErrorData.new(source: self.class, payload:),
                                                   log_message:)
            )
          end
        end
      end
    end
  end
end
