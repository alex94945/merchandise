class DashboardStatsService < DashboardBaseService

  def perform
    {
      complete_appointments: complete_appointents,
      incomplete_appointments: incomplete_appointments,
      created_styles: all_styles.select{ |s| s.status == 'created'},
      pending_styles: all_styles.select{ |s| s.status == 'pending'},
      placed_styles: all_styles.select{ |s| s.status == 'placed'},
      incomplete_styles: all_styles.select{ |s| s.status == 'created' || s.status == 'pending'}, #meh?

    }
  end

  private

    def appointments
      date_range = @start_date..@end_date
      @appointments ||= @user.appointments.joins(:styles).where(styles: { delivery_date: date_range })
    end

    def complete_appointents
      appointments - incomplete_appointments
    end

    def incomplete_appointments
      appointments.joins(:styles).where(styles: {status: Style::INCOMPLETE_STATUSES}).distinct
    end

    def all_styles
      # calling .all hits the db, and memoizes the result
      # into array containing all styles for these appointments, this no longer creates an n+1
      @all_styles ||= Style.includes(:appointment).where(appointment_id: appointments.uniq).all
    end

end
