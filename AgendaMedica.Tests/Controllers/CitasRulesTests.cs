using AgendaMedica.Controllers;
using AgendaMedica.Middleware;
using AgendaMedica.Models;
using AgendaMedica.Services;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Xunit;

namespace AgendaMedica.Tests.Controllers;

public class CitasRulesTests
{
    [Fact]
    public async Task Regla_ConflictoHorario_DebeRetornar409ConSugerencias()
    {
        var service = new Mock<ICitaService>();
        var request = CrearRequest(new TimeSpan(9, 0, 0));
        var sugerencias = new List<HorarioSugeridoResponse>
        {
            new() { MedicoId = 1, FechaHoraInicio = new DateTime(2026, 3, 23, 9, 30, 0), FechaHoraFin = new DateTime(2026, 3, 23, 10, 0, 0), DuracionMinutos = 30, DiferenciaMinutosContraSolicitado = 30 }
        };

        service.Setup(s => s.AgendarAsync(request))
            .ThrowsAsync(new RulesException("El médico ya tiene una cita en ese horario.", 409));
        service.Setup(s => s.SugerirHorariosAsync(request.MedicoId, request.Fecha, request.HoraInicio, 3))
            .ReturnsAsync(sugerencias);

        var controller = new CitasController(service.Object);

        var result = await controller.Agendar(request);

        var conflict = result.Result.Should().BeOfType<ConflictObjectResult>().Subject;
        var payload = conflict.Value!;
        payload.GetType().GetProperty("status")!.GetValue(payload).Should().Be(409);
        var sugerenciasPayload = payload.GetType().GetProperty("sugerencias")!.GetValue(payload) as IEnumerable<HorarioSugeridoResponse>;
        sugerenciasPayload.Should().NotBeNull();
        sugerenciasPayload!.Should().HaveCount(1);
    }

    [Fact]
    public async Task Regla_FueraHorario_DebeRetornar409ConSugerencias()
    {
        var service = new Mock<ICitaService>();
        var request = CrearRequest(new TimeSpan(14, 0, 0));
        var sugerencias = new List<HorarioSugeridoResponse>
        {
            new() { MedicoId = 1, FechaHoraInicio = new DateTime(2026, 3, 23, 13, 30, 0), FechaHoraFin = new DateTime(2026, 3, 23, 14, 0, 0), DuracionMinutos = 30, DiferenciaMinutosContraSolicitado = 30 }
        };

        service.Setup(s => s.AgendarAsync(request))
            .ThrowsAsync(new RulesException("La cita solicitada está fuera del horario de consulta del médico.", 409));
        service.Setup(s => s.SugerirHorariosAsync(request.MedicoId, request.Fecha, request.HoraInicio, 3))
            .ReturnsAsync(sugerencias);

        var controller = new CitasController(service.Object);

        var result = await controller.Agendar(request);

        var conflict = result.Result.Should().BeOfType<ConflictObjectResult>().Subject;
        var payload = conflict.Value!;
        payload.GetType().GetProperty("status")!.GetValue(payload).Should().Be(409);
        var sugerenciasPayload = payload.GetType().GetProperty("sugerencias")!.GetValue(payload) as IEnumerable<HorarioSugeridoResponse>;
        sugerenciasPayload.Should().NotBeNull();
        sugerenciasPayload!.Should().HaveCount(1);
    }

    [Fact]
    public async Task Regla_ConflictoSinSugerencias_DebeRetornarListaVacia()
    {
        var service = new Mock<ICitaService>();
        var request = CrearRequest(new TimeSpan(14, 0, 0));

        service.Setup(s => s.AgendarAsync(request))
            .ThrowsAsync(new RulesException("El médico no tiene horario de consulta configurado para ese día.", 409));
        service.Setup(s => s.SugerirHorariosAsync(request.MedicoId, request.Fecha, request.HoraInicio, 3))
            .ThrowsAsync(new RulesException("No se pudieron generar sugerencias.", 400));

        var controller = new CitasController(service.Object);

        var result = await controller.Agendar(request);

        var conflict = result.Result.Should().BeOfType<ConflictObjectResult>().Subject;
        var payload = conflict.Value!;
        payload.GetType().GetProperty("status")!.GetValue(payload).Should().Be(409);
        var sugerenciasPayload = payload.GetType().GetProperty("sugerencias")!.GetValue(payload) as IEnumerable<HorarioSugeridoResponse>;
        sugerenciasPayload.Should().NotBeNull();
        sugerenciasPayload!.Should().BeEmpty();
    }

    [Fact]
    public async Task Regla_DuracionEspecialidad_DebeRetornarDuracionEnRespuesta()
    {
        var service = new Mock<ICitaService>();
        var request = CrearRequest(new TimeSpan(10, 0, 0));
        var cita = new CitaResponse
        {
            Id = 22,
            MedicoId = 1,
            PacienteId = 1,
            FechaHoraInicio = new DateTime(2026, 3, 23, 10, 0, 0),
            FechaHoraFin = new DateTime(2026, 3, 23, 10, 30, 0),
            Motivo = "Consulta general",
            Estado = "Programada",
            EspecialidadNombre = "Cardiología",
            DuracionMinutos = 30
        };

        service.Setup(s => s.AgendarAsync(request)).ReturnsAsync(cita);
        var controller = new CitasController(service.Object);

        var result = await controller.Agendar(request);

        var created = result.Result.Should().BeOfType<CreatedResult>().Subject;
        var payload = created.Value.Should().BeOfType<CitaResponse>().Subject;
        payload.EspecialidadNombre.Should().Be("Cardiología");
        payload.DuracionMinutos.Should().Be(30);
    }

    [Fact]
    public async Task Regla_AlertaCancelaciones_DebeRetornarBanderaActiva()
    {
        var service = new Mock<ICitaService>();
        var request = CrearRequest(new TimeSpan(11, 0, 0));
        var cita = new CitaResponse
        {
            Id = 23,
            MedicoId = 1,
            PacienteId = 1,
            FechaHoraInicio = new DateTime(2026, 3, 23, 11, 0, 0),
            FechaHoraFin = new DateTime(2026, 3, 23, 11, 30, 0),
            Motivo = "Control",
            Estado = "Programada",
            AlertaCancelaciones = true,
            CancelacionesUltimos30Dias = 3
        };

        service.Setup(s => s.AgendarAsync(request)).ReturnsAsync(cita);
        var controller = new CitasController(service.Object);

        var result = await controller.Agendar(request);

        var created = result.Result.Should().BeOfType<CreatedResult>().Subject;
        var payload = created.Value.Should().BeOfType<CitaResponse>().Subject;
        payload.AlertaCancelaciones.Should().BeTrue();
        payload.CancelacionesUltimos30Dias.Should().NotBeNull();
        payload.CancelacionesUltimos30Dias!.Value.Should().BeGreaterThanOrEqualTo(3);
    }

    private static AgendarCitaRequest CrearRequest(TimeSpan horaInicio)
    {
        return new AgendarCitaRequest
        {
            MedicoId = 1,
            PacienteId = 1,
            Fecha = new DateTime(2026, 3, 23),
            HoraInicio = horaInicio,
            Motivo = "Prueba"
        };
    }
}
