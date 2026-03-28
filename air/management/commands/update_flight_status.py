import os
from django.core.management.base import BaseCommand
from django.utils import timezone
from air.models import Flight, FlightStatusChoices, Ticket, TicketStatusChoices

class Command(BaseCommand):
    help = "Updates flight and ticket statuses"

    def handle(self, *args, **options):
        now = timezone.now()
        self.stdout.write(f"[{now}] Task started")

        departed_flights = Flight.objects.filter(
            departure_time__lte=now,
            status=FlightStatusChoices.UPCOMING,
        )
        count_departed = departed_flights.update(status=FlightStatusChoices.IN_AIR)
        self.stdout.write(f"Updated {count_departed} flights to 'IN_AIR'")

        arrived_flights = Flight.objects.filter(
            arrival_time__lte=now,
            status=FlightStatusChoices.IN_AIR,
        )
        count_arrived = arrived_flights.update(status=FlightStatusChoices.ARRIVED)
        self.stdout.write(f"Updated {count_arrived} flights to 'ARRIVED'")

        updated_flight_ids = Flight.objects.filter(
            departure_time__lte=now,
            status=FlightStatusChoices.IN_AIR,
        ).values_list("id", flat=True)

        used_tickets = Ticket.objects.filter(
            flight_id__in=updated_flight_ids,
            status=TicketStatusChoices.UPCOMING,
            is_checked_in=True,
            is_boarded=True,
        )
        count_used_tickets = used_tickets.update(status=TicketStatusChoices.USED)
        self.stdout.write(f"Updated {count_used_tickets} tickets to 'USED'")

        late_tickets = Ticket.objects.filter(
            flight_id__in=updated_flight_ids,
            status=TicketStatusChoices.UPCOMING,
        ).exclude(
            is_checked_in=True,
            is_boarded=True,
        )
        count_late_tickets = late_tickets.update(status=TicketStatusChoices.LATE)
        self.stdout.write(f"Updated {count_late_tickets} tickets to 'LATE'")

        self.stdout.write(f"[{timezone.now()}] Task finished")